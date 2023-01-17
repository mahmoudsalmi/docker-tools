# [SALMI.DEV] Docker tools scripts

## Instalation

```sh
stow ./tools
```

## Backup/Restore volumes

- example of `backup`:
```sh
docker-tools volumes backup <volume_name>
```

- example of `restore`:
```sh
docker-tools volumes restore <volume_name> [<backup_filename>]
```

