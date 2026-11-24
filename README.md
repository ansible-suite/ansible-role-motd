# motd

1. [Účel](#účel)
1. [Podporované systémy](#podporované-systémy)
1. [Použití](#použití)
1. [Default variables](#default-variables)
     * [Needrestart](#needrestart)
     * [Banner](#banner)
     * [End of support (EOL)](#end-of-support-eol)
     * [Pending updates](#pending-updates)
1. [Vývoj](#vývoj)
1. [Licence](#licence)


## Účel

Nastaví přihlašovací MOTD na Debianu:

- stav `needrestart` (cachovaný skriptem a cronem, aby nebrzdil SSH login),
- volitelný figlet banner s hostname (`/etc/update-motd.d/05-banner`),
- volitelné informace o konci podpory Debianu EOL/LTS/ELTS
  (`/etc/update-motd.d/10-eol`),
- počet čekajících aktualizací balíčků včetně bezpečnostních
  (`/etc/update-motd.d/98-updates`); cache se přepočítá cronem a apt hookem
  `/etc/apt/apt.conf.d/99motd-updates` po `apt update` a dpkg, `apt update` role
  sama nespouští,
- vyprázdněný statický `/etc/motd` (text o licenci Debianu).

## Podporované systémy

Debian (bookworm, trixie) a odvozené distribuce z rodiny `Debian`. Role používá
`apt` a `update-motd.d`. Na ostatních systémech se pro daného hosta přeskočí
(`meta: end_host`), nic se nemění.


## Použití

```yml
- hosts: all
  become: true
  roles:
    - ansible-suite.motd
```

Kontrola bez změn:

```bash
ansible-playbook playbook.yml --limit <hostname> --check --diff
```


## Default variables

### Needrestart

#### motd_needrestart_cache_file
**String**. File with the cached output of needrestart shown in the login MOTD.

``` yml
motd_needrestart_cache_file: /var/cache/needrestart.motd
```

#### motd_needrestart_cache_script
**String**. Script that refreshes the needrestart cache.

``` yml
motd_needrestart_cache_script: /usr/local/sbin/needrestart-cache
```

#### motd_needrestart_cron_minute
**String**. Cron minute field for the needrestart cache refresh.

``` yml
motd_needrestart_cron_minute: "*/30"
```

### Banner

#### motd_banner_enabled
**Boolean**. Figlet banner with the hostname at the top of the MOTD.

``` yml
motd_banner_enabled: true
```

#### motd_banner_font
**String**. Figlet font used for the banner (`figlet -f`), e.g. small, standard,
slant, big.

``` yml
motd_banner_font: small
```

### End of support (EOL)

#### motd_eol_enabled
**Boolean**. Show end of support information (EOL/LTS/ELTS) for the installed
Debian release.

``` yml
motd_eol_enabled: true
```

### Pending updates

#### motd_updates_enabled
**Boolean**. Show the number of pending package updates in the MOTD (counted from
the existing apt cache, the role never runs `apt update` itself).

``` yml
motd_updates_enabled: true
```

#### motd_updates_cache_file
**String**. File with the cached updates summary shown in the MOTD.

``` yml
motd_updates_cache_file: /var/cache/updates.motd
```

#### motd_updates_cache_script
**String**. Script that refreshes the updates cache.

``` yml
motd_updates_cache_script: /usr/local/sbin/updates-cache
```

#### motd_updates_cron_minute
**String**. Cron minute field for the updates cache refresh.

``` yml
motd_updates_cron_minute: "*/30"
```

#### motd_updates_list_max
**Integer**. How many package names to list below the summary (0 = summary only).

``` yml
motd_updates_list_max: 0
```


## Vývoj

README.md se **negeneruje ručně**. Skládá se z `docs/*.md` a z komentářů
v `defaults/main.yml` (a `vars/*.yml`):

```bash
make        # nápověda
make doc    # přegeneruje README.md
make lint   # ansible-lint + yamllint
```

Pro `defaults/main.yml` a `vars/` platí:
- Komentáře v kódu jsou anglicky.
- Použij syntaxi popsanou v hlavičce souboru, nejjednodušší je zkopírovat
  existující blok proměnné.
- Dokumentace se píše do komentáře nad proměnnou. Ručně psané části README jsou
  v `docs/` (`00`–`02`, `70`–`80`).
- Plán podpory RHEL je v [TODO.md](TODO.md).


## Licence

[MIT](LICENSE)
