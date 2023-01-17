# [SALMI.DEV] Docker tools scripts

## Requirments

- shell-tools

## Instalation

```sh
stow ./tools -t $HOME
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

