# TODO

## Podpora RHEL (rodina `RedHat`)

Role zatím podporuje jen rodinu `Debian` (na ostatních systémech se přeskočí
přes `meta: end_host`).

### Jak se MOTD vypisuje

- `/etc/update-motd.d/` je specifické pro Debian. RHEL `pam_motd` čte jen
  statické soubory z `/etc/motd.d/`, `/run/motd.d/` a `/usr/lib/motd.d/`.
- Cache soubory jsou už statický text, takže cache skript na RHEL zapíše výstup
  přímo do `/etc/motd.d/NN-nazev`. Obalovací skripty `98-updates` a
  `99-needrestart` se na RHEL nenasazují.
- Banner a EOL se na RHEL vygenerují při nasazení, nebo stejným cache skriptem.
- Kontrola OS: `ansible_facts['os_family'] in ['Debian', 'RedHat']`.

### Co je potřeba nahradit

| Funkce | Debian | RHEL |
| --- | --- | --- |
| Balíčky | `apt` | `ansible.builtin.package` (nebo `dnf`) |
| needrestart | `needrestart -r l` | `needs-restarting -r` a `-s` (balíček `dnf-utils`) |
| Čekající aktualizace | `apt-get -s dist-upgrade` | `dnf -q check-update --cacheonly` a `dnf updateinfo list security --cacheonly` |
| Hook po změně balíčků | apt hook | systemd timer nebo `python3-dnf-plugin-post-transaction-actions` |
| EOL | `distro-info-data` | žádný ekvivalent (viz níže) |
| figlet | základní repozitáře | až z EPEL |

### K rozhodnutí

- **EOL na RHEL**: neexistuje ekvivalent `distro-info`. Buď proměnná
  `motd_eol_dates` (mapa verze → datum konce podpory v `defaults`), nebo EOL na
  RHEL vypnout.
- **figlet**: dostupný jen z EPEL. Na RHEL výchozí `motd_banner_enabled: false`,
  nebo banner přeskočit, když balíček chybí.
- **Cron**: sjednotit na systemd timer pro obě rodiny (není potřeba `cronie`),
  alternativně nainstalovat `cronie` na RHEL.

### Struktura role

- `vars/Debian.yml` a `vars/RedHat.yml` (názvy balíčků, cesty `motd_dir`,
  příkazy), načítané přes `include_vars` s `with_first_found`.
- `tasks/main.yml` zůstane společné jádro (kontrola OS, načtení vars, vstup do
  `tasks/{{ ansible_facts['os_family'] }}.yml`).
- Šablony `needrestart-cache.sh.j2` a `updates-cache.sh.j2` s větvemi pro
  Debian a RHEL, případně dvě varianty souborů.
- SELinux: ověřit `restorecon` pro `/etc/motd.d`; skripty v `/usr/local/sbin` a
  cache v `/var/cache` by neměly vadit.

### Pořadí práce

1. Rozdělit roli na společnou část a Debian část beze změny chování
   (`vars/Debian.yml`).
2. Přidat RedHat větev: `needs-restarting`, dnf updates, `motd.d`, timer.
3. Otestovat v kontejneru (např. Rocky 9) v `--check`, potom ostře. Lobsang je
   Debian, takže ho RHEL změny nesmí ovlivnit.
