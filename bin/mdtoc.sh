#!/bin/sh
#
# Purpose {{{
# Generate a Markdown table of contents from the headings of Markdown files.
#   1. Only "##" (level 1 in the TOC) and "###" (level 2) headings are used.
#   2. Headings inside fenced code blocks are ignored.
#   3. Files are processed in the order given; the destination file itself and
#      files named "00.*" are skipped, so it can live in the same docs/ glob.
#   4. Anchors follow the GitHub rules (lowercase, punctuation removed, spaces
#      replaced by hyphens). Duplicate headings are not de-duplicated.
# }}}
PROGNAME=$(basename "${0}"); readonly PROGNAME

usage() {
	cat <<- HELP
usage: ${PROGNAME} [--title TITLE] [--dest FILE] FILE...

Generate a table of contents for the headings of the given Markdown files.

OPTIONS :
    -t,--title
        Title written as the first line (# TITLE). Default: none.

    -d,--dest
        Write the table of contents to FILE. Default: stdout.

    -h,--help
        Print this help message.

EXAMPLE :
    ${PROGNAME} --title motd --dest docs/00.toc.md docs/*.md
HELP
}

title=""
dest=""
while [ "${#}" -gt 0 ]; do
	case "${1}" in
		-t|--title) title="${2}"; shift 2 ;;
		-d|--dest) dest="${2}"; shift 2 ;;
		-h|--help) usage; exit 0 ;;
		--) shift; break ;;
		-*) printf 'ERROR - %s: unknown option %s\n' "${PROGNAME}" "${1}" >&2; exit 64 ;;
		*) break ;;
	esac
done

if [ "${#}" -eq 0 ]; then
	printf 'ERROR - %s: expect at least one input file (see --help)\n' "${PROGNAME}" >&2
	exit 64
fi

## sed needs a UTF-8 locale to lowercase non-ASCII letters (e.g. "Účel")
export LC_ALL=C.UTF-8

toc() {
	[ -n "${title}" ] && printf '# %s\n\n' "${title}"

	for file in "${@}"; do
		case "$(basename "${file}")" in
			00.*) continue ;;
		esac
		[ -n "${dest}" ] && [ "${file}" = "${dest}" ] && continue

		## level<TAB>text for each "##" / "###" heading outside code fences
		awk '
			/^```/ { fence = !fence; next }
			fence { next }
			/^### / { sub(/^### +/, ""); print "2\t" $0; next }
			/^## /  { sub(/^## +/, "");  print "1\t" $0 }
		' "${file}"
	done | while IFS="$(printf '\t')" read -r level text; do
		anchor=$(printf '%s' "${text}" \
			| sed -e 's/.*/\L&/' -e 's/[^[:alnum:] _-]//g' -e 's/ /-/g')
		if [ "${level}" = "1" ]; then
			printf '1. [%s](#%s)\n' "${text}" "${anchor}"
		else
			printf '     * [%s](#%s)\n' "${text}" "${anchor}"
		fi
	done
	printf '\n'
}

if [ -n "${dest}" ]; then
	toc "${@}" > "${dest}"
else
	toc "${@}"
fi
