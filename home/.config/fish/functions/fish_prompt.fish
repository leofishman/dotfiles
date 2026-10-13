function fish_prompt --description 'Simple prompt: directory + git branch'
    set -l dir (prompt_pwd)
    set -l git_info (fish_vcs_prompt 2>/dev/null)
    set -l status_mark ""
    if test $status -ne 0
        set status_mark (set_color red)" ✗"(set_color normal)
    end
    echo -n (set_color cyan)$dir(set_color normal)$git_info$status_mark" "
    echo -n (set_color yellow)"❯ "(set_color normal)
end