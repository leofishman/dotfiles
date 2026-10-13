function qreply --description 'Reply to @quebracho.digital mail through the SER5 server (Brevo)'
    # qreply                 → list recent inbound mail
    # qreply show <id>       → show one inbound message
    # qreply <id> "text"     → reply (threaded automatically when message_id exists)
    #
    # The host comes from a universal variable (kept in fish_variables, not in this repo):
    #   set -U QREPLY_HOST user@server-lan-ip
    # Use the LAN IP rather than mDNS: it is also reachable over a WireGuard VPN
    # that routes the LAN subnet, where mDNS does not resolve.
    if not set -q QREPLY_HOST
        echo "qreply: set the server first: set -U QREPLY_HOST user@host" >&2
        return 1
    end
    set -l host $QREPLY_HOST
    set -l script '~/quebrachos/scripts/mail-reply.sh'
    switch (count $argv)
        case 0
            ssh $host "$script list"
        case '*'
            switch $argv[1]
                case show list
                    ssh $host "$script $argv"
                case '*'
                    # argv[1]=id, the rest is the reply text
                    set -l id $argv[1]
                    set -l body (string join ' ' $argv[2..-1])
                    if test -z "$body"
                        echo "usage: qreply <id> \"reply text\"" >&2
                        return 2
                    end
                    ssh $host "$script reply $id "(string escape -- $body)
            end
    end
end
