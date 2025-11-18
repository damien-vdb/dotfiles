#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default package manager
PACKAGE_MANAGER="${PACKAGE_MANAGER:-apt}"

# Colors
CYAN='\033[36m'
GREEN='\033[32m'
RED='\033[31m'
YELLOW='\033[33m'
RESET='\033[0m'

usage() {
    cat << EOF
Usage: $0 [OPTIONS] <command> [modules...]

Options:
    --pm <manager>         Package manager to use (apt, dnf, pacman, etc.)
                          Default: apt (or set PACKAGE_MANAGER env var)

Commands:
    setup                  Interactive setup with module selection
    install <modules>      Install specified modules
    list                   List all available modules
    host                   Install modules for current hostname

Examples:
    $0 setup
    $0 install base git docker
    $0 --pm dnf install base git
    $0 host
    $0 list

Environment Variables:
    PACKAGE_MANAGER       Package manager to use (overridden by --pm)
EOF
    exit 1
}

strip_prefix() {
    local name=$1
    # Remove numeric prefix (e.g., "01-base" -> "base")
    echo "$name" | sed 's/^[0-9]\+-//'
}

find_module_dir() {
    local module=$1

    # Check if exact directory exists (with or without prefix)
    if [[ -d "$DOTFILES_DIR/$module" ]]; then
        echo "$DOTFILES_DIR/$module"
        return 0
    fi

    # Look for directory with numeric prefix
    for dir in "$DOTFILES_DIR"/*-"$module"/; do
        if [[ -d "$dir" ]]; then
            echo "${dir%/}"
            return 0
        fi
    done

    return 1
}

list_modules() {
    echo -e "${CYAN}Available modules:${RESET}"
    for dir in "$DOTFILES_DIR"/*/; do
        [[ ! -d "$dir" ]] && continue

        module=$(basename "$dir")
        module_name=$(strip_prefix "$module")

        if [[ -f "$dir/install.sh" ]]; then
            echo "  $module ($module_name)"
        fi
    done
}

install_module() {
    local module=$1
    local module_dir

    module_dir=$(find_module_dir "$module")
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Module '$module' not found${RESET}"
        return 1
    fi

    if [[ ! -f "$module_dir/install.sh" ]]; then
        echo -e "${RED}Error: No install.sh found for module '$module'${RESET}"
        return 1
    fi

    local module_name=$(strip_prefix "$(basename "$module_dir")")
    echo -e "${CYAN}Installing $module_name...${RESET}"
    cd "$module_dir"
    if PACKAGE_MANAGER="$PACKAGE_MANAGER" bash install.sh; then
        echo -e "${GREEN}✓ $module_name installed${RESET}"
    else
        echo -e "${RED}✗ $module_name installation failed${RESET}"
        return 1
    fi
}

interactive_setup() {
    # Check if whiptail is available
    if ! command -v whiptail &> /dev/null; then
        echo -e "${RED}Error: whiptail is required for interactive setup${RESET}"
        echo -e "${YELLOW}Install it with: sudo apt install whiptail (or equivalent)${RESET}"
        exit 1
    fi

    # Build module list for whiptail
    local options=()
    local all_modules=()

    for dir in "$DOTFILES_DIR"/*/; do
        [[ ! -d "$dir" ]] && continue
        [[ ! -f "$dir/install.sh" ]] && continue

        module=$(basename "$dir")
        module_name=$(strip_prefix "$module")
        all_modules+=("$module")

        # Pre-select base and git
        if [[ "$module_name" == "base" ]] || [[ "$module_name" == "git" ]]; then
            options+=("$module" "$module_name" "ON")
        else
            options+=("$module" "$module_name" "OFF")
        fi
    done

    # Show checklist dialog
    local selected
    selected=$(whiptail --title "Dotfiles Setup" \
        --checklist "Select modules to install (in order):" \
        20 60 12 \
        "${options[@]}" \
        3>&1 1>&2 2>&3)

    # Check if user cancelled
    if [[ $? -ne 0 ]]; then
        echo -e "${YELLOW}Setup cancelled${RESET}"
        exit 0
    fi

    # Parse selected modules (whiptail returns quoted list)
    selected=$(echo "$selected" | tr -d '"')

    if [[ -z "$selected" ]]; then
        echo -e "${YELLOW}No modules selected${RESET}"
        exit 0
    fi

    # Convert to array and sort by directory name (numeric prefix ensures order)
    local selected_array=()
    for module in $selected; do
        selected_array+=("$module")
    done

    # Sort selected modules by their numeric prefix
    IFS=$'\n' selected_sorted=($(sort <<<"${selected_array[*]}"))
    unset IFS

    # Show confirmation
    echo -e "${CYAN}Selected modules (in installation order):${RESET}"
    for module in "${selected_sorted[@]}"; do
        module_name=$(strip_prefix "$module")
        echo "  - $module_name"
    done
    echo ""

    read -p "Continue with installation? [Y/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ -n $REPLY ]]; then
        echo -e "${YELLOW}Installation cancelled${RESET}"
        exit 0
    fi

    # Install selected modules in order
    for module in "${selected_sorted[@]}"; do
        install_module "$module" || {
            echo -e "${RED}Installation aborted due to error${RESET}"
            exit 1
        }
    done

    echo -e "${GREEN}All selected modules installed successfully!${RESET}"
}

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        --pm)
            PACKAGE_MANAGER="$2"
            shift 2
            ;;
        setup)
            interactive_setup
            exit 0
            ;;
        install)
            shift
            if [[ $# -eq 0 ]]; then
                echo -e "${RED}Error: No modules specified${RESET}"
                usage
            fi
            for module in "$@"; do
                install_module "$module"
            done
            exit 0
            ;;
        list)
            list_modules
            exit 0
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown option or command: $1${RESET}"
            usage
            ;;
    esac
done

# If no arguments provided, show usage
usage
