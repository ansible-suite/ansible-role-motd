# Role: motd

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

## Proměnné

| Proměnná | Výchozí | Popis |
| --- | --- | --- |
| `motd_needrestart_cache_file` | `/var/cache/needrestart.motd` | Soubor s cache výstupu needrestart |
| `motd_needrestart_cache_script` | `/usr/local/sbin/needrestart-cache` | Skript obnovující cache |
| `motd_needrestart_cron_minute` | `"*/30"` | Minuta cronu obnovy cache |
| `motd_banner_enabled` | `true` | Figlet banner s hostname |
| `motd_banner_font` | `small` | Font figletu pro banner (`figlet -f`) |
| `motd_eol_enabled` | `true` | Informace o EOL nainstalované verze Debianu |
| `motd_updates_enabled` | `true` | Počet balíčků k aktualizaci (z existující apt cache) |
| `motd_updates_cache_file` | `/var/cache/updates.motd` | Cache pro MOTD |
| `motd_updates_cache_script` | `/usr/local/sbin/updates-cache` | Skript obnovující cache |
| `motd_updates_cron_minute` | `"*/30"` | Minuta cronu obnovy cache |
| `motd_updates_list_max` | `0` | Kolik názvů balíčků vypsat pod souhrn (0 = jen souhrn) |

## Použití

```yml
- hosts: all
  become: true
  roles:
    - ansible-suite.motd
```

Kontrola bez změn: 
```bash
ansible-playbook playbooks/motd.yml --limit <hostname> --check --diff
```
