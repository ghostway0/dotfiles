#!/bin/bash

PLATFORM=$(uname | tr '[:upper:]' '[:lower:]')
DRY_RUN=false
BACKUP=true
TARGET_DIR=""
COMMAND=""
PACKAGES=()
EXCLUDE=()

INFO="\033[1;34m[INFO]\033[0m"
WARN="\033[1;33m[WARN]\033[0m"
ERROR="\033[1;31m[ERROR]\033[0m"

HELP="Usage: $0 {install|update} --platform <platform> [target_dir] [--dry-run] [--no-backup] [--packages package1,package2] [--exclude exclude1,exclude2]"

if ! command -v sops &> /dev/null; then
    echo -e "$ERROR sops not installed."
    exit 1
fi

if ! command -v stow &> /dev/null; then
    echo -e "$ERROR stow not installed."
    exit 1
fi

COMMAND="$1"
shift

while [[ "$1" != "" ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            ;;
        --no-backup)
            BACKUP=false
            ;;
        --platform)
            shift
            PLATFORM="$1"
            ;;
        --packages)
            shift
            IFS=',' read -r -a PACKAGES <<< "$1"
            ;;
        --exclude)
            shift
            IFS=',' read -r -a EXCLUDE <<< "$1"
            ;;
        *)
            TARGET_DIR="$1"
            ;;
    esac
    shift
done

generate_unique_backup_name() {
    local base_name="$1.bak.dec"
    local count=1
    local unique_name="$base_name"

    while [[ -f "$unique_name" ]]; do
        unique_name="$1.bak.dec.$count"
        count=$((count + 1))
    done

    echo "$unique_name"
}

backup_file() {
    local file="$1"
    local temp_file="$2"

    if [[ -f "$file" ]]; then
        if ! cmp -s "$temp_file" "$file"; then
            local backup_file=$(generate_unique_backup_name "$file")
            echo -e "$file -> $backup_file"

            if ! $DRY_RUN; then
                cp "$file" "$backup_file"
            fi
        fi
    fi
}

is_excluded() {
    local name="$1"
    for exclude in "${EXCLUDE[@]}"; do
        if [[ "$name" == *"$exclude"* ]]; then
            return 0
        fi
    done
    return 1
}

install_files() {
    export SOPS_AGE_KEY_FILE=/dev/stdin

    echo "filtering for $PLATFORM"

    for dir in */; do
        if [[ -d "$dir" ]]; then
            if is_excluded "$dir"; then
                echo -e "skipped $dir"
                continue
            fi

            if [[ "$dir" == *-$PLATFORM/ || "$dir" != *-*/ ]]; then
                if [[ ${#PACKAGES[@]} -eq 0 || " ${PACKAGES[@]} " =~ " $(basename "$dir") " ]]; then
                    echo -e "$dir"

                    find "$dir" -type f -name '*.sopsenc*' | while read -r enc_file; do
                        if is_excluded "$enc_file"; then
                            echo -e "$WARN Skipping excluded file $enc_file"
                            continue
                        fi

                        decrypted_file="${enc_file%.sopsenc*}"
                        temp_file=$(mktemp)

                        echo "$AGE_KEY" | sops --input-type json --decrypt "$enc_file" > "$temp_file"

                        if [[ -f "$decrypted_file" && $BACKUP == true ]]; then
                            backup_file "$decrypted_file" "$temp_file"
                        fi

                        if ! $DRY_RUN; then
                            echo "$decrypted_file <~ $enc_file"
                            mv "$temp_file" "$decrypted_file"
                        else
                            rm "$temp_file"
                        fi
                    done

                    if ! $DRY_RUN; then
                        if ! stow "$dir" -t "$TARGET_DIR"; then
                            echo -e "$ERROR Failed to stow $dir"
                            exit 1
                        fi
                    fi
                fi
            fi
        fi
    done
}

update_files() {
    echo -e "$AGE_KEY"

    echo "filtering for $PLATFORM"

    for dir in */; do
        if [[ -d "$dir" ]]; then
            if is_excluded "$dir"; then
                echo -e "$WARN Skipping excluded directory $dir"
                continue
            fi

            if [[ "$dir" == *-$PLATFORM/ || "$dir" != *-*/ ]]; then
                if [[ ${#PACKAGES[@]} -eq 0 || " ${PACKAGES[@]} " =~ " $(basename "$dir") " ]]; then
                    find "$dir" -type f ! -name '*.sopsenc*' | while read -r orig_file; do
                        if is_excluded "$orig_file"; then
                            echo -e "$WARN Skipping excluded file $orig_file"
                            continue
                        fi

                        file_type=$(find "$dir" -type f -name "$(basename "$orig_file").sopsenc.*" | grep -o '\.\w\+$')

                        if [[ -n "$file_type" ]]; then
                            encrypted_file="${orig_file}.sopsenc$file_type"
                            echo -e "$orig_file ~> $encrypted_file"

                            if ! $DRY_RUN; then
                                echo "$AGE_KEY" | sops --age $(</dev/stdin) --encrypt --input-type="${file_type#.}" "$orig_file" > "$encrypted_file"
                            fi
                        fi
                    done
                fi
            fi
        fi
    done
}

if $DRY_RUN; then
    echo -e "$INFO [DRY RUN]"
fi

case "$COMMAND" in
    install)
        read -s -p "Enter age secret: " AGE_KEY
        echo

        if [[ -z "$TARGET_DIR" ]]; then
            echo -e "$ERROR Target directory not specified."
            exit 1
        fi

        if [[ ! -d "$TARGET_DIR" ]]; then
            echo -e "$ERROR Target directory '$TARGET_DIR' does not exist."
            exit 1
        fi

        install_files
        ;;
    update)
        read -s -p "Enter age recipient: " AGE_KEY
        echo
        update_files
        ;;
    --help)
        echo -e "$HELP"
        ;;
    *)
        echo -e "$ERROR $HELP"
        ;;
esac

