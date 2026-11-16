# Role: motd

## Účel

Nastaví přihlašovací MOTD na Debianu:

- stav `needrestart` (cachovaný skriptem a cronem, aby nebrzdil SSH login),
- volitelný figlet banner s hostname (`/etc/update-motd.d/05-banner`),
- volitelné informace o konci podpory Debianu EOL/LTS/ELTS
  (`/etc/update-motd.d/10-eol`),
- vyprázdněný statický `/etc/motd` (text o licenci Debianu).

## Podporované systémy

Debian (bookworm, trixie). Role používá `apt` a `update-motd.d`.

## Proměnné

| Proměnná | Výchozí | Popis |
| --- | --- | --- |
| `motd_needrestart_cache_file` | `/var/cache/needrestart.motd` | Soubor s cache výstupu needrestart |
| `motd_needrestart_cache_script` | `/usr/local/sbin/needrestart-cache` | Skript obnovující cache |
| `motd_needrestart_cron_minute` | `"*/30"` | Minuta cronu obnovy cache |
| `motd_banner_enabled` | `true` | Figlet banner s hostname |
| `motd_eol_enabled` | `true` | Informace o EOL nainstalované verze Debianu |

## Použití

```yml
- hosts: all
  become: true
  roles:
    - ansible-suite.motd
```

Kontrola bez změn: `ansible-playbook playbooks/motd.yml --limit lobsang --check --diff`.
