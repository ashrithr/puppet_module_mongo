# == definition mongodb::limits::conf
#
# Manages user's nofile and proc limits
#
# === Parameters
# [*domain*]
#   A username or a groupname with @group syntax, the wildcard '*' for default
#   entry and the wildcard '%' for maxlogins limit only, can also be used with
#   %group syntax.
#   An uid range as <min_uid>:<max_uid>
#   A gid range as @<min_gid>:<max_gid>
#   A gid specified as %:<gid>
#   Default to user running mongod process.
#
# [*type*]
#   Type of the limit soft/hard. Default to soft.
#   'hard' -> for enforcing hard resource limits, these limits are set by the
#             superuser and enforced by the kernel, the user cannot raise his
#             requirement of system resources above such values.
#   'soft' -> for enforcing soft limits, these limits are ones that the user
#             can move up or down within the specified permitted range by any
#             pre-existing hard limits.
#    '-'   -> For enforcing both soft and hard resources limits together.
#
# [*item*]
#   Item to set the limits to:
#   'core' -> limits the core file size (KB)
#   'data' -> maximum data size (KB)
#   'fsize' -> maximum file size (KB)
#   'memlock' -> maximum locked-in memeory address space (KB)
#   'nofile' -> maximum number of open files limits
#   'rss' -> maximum resident set size (KB)
#   'stack' -> maximum stack size (KB)
#   'cpu' -> maximum CPU time (minutes)
#   'nproc' -> maximum number of processes
#   'maxlogins' -> maximum number of logins for this user except for this with
#                  uid=0
#   'maxsyslogins' -> maximum number of all logins on system
#   'locks' -> maximum locked files
#   'sigpending' -> maximum number of pending signals
#   'msgqueue' -> maximum memory used by POSIX message queues (bytes)
#   'nice' -> maximum nice priority allowed to raise to, values:[-20, 19]
#   'rtprio' -> maximum realtime priority allowed to raise to
#    All the items suppor the values '-1', 'unlimited', 'infinty' indicating
#    no limit, except for priority and nice
#
# [*value*]
#   value to use for a specified item
#
define mongodb::limits::conf (
  $domain = $mongodb::params::run_as_user,
  $type = soft,
  $item = nofile,
  $value = 64000
) {
  # guid of this entry
  $key = "${domain}/${type}/${item}"

  # augtool> match /files/etc/security/limits.conf/domain[.="root"][./type="hard" and ./item="nofile" and ./value="10000"]
  $context = '/files/etc/security/limits.conf'

  $path_list  = "domain[.=\"${domain}\"][./type=\"${type}\" and ./item=\"${item}\"]"
  $path_exact = "domain[.=\"${domain}\"][./type=\"${type}\" and ./item=\"${item}\" and ./value=\"${value}\"]"

  augeas { "limits_conf/${key}":
    context => $context,
    onlyif  => "match ${path_exact} size != 1",
    changes => [
                # remove all matching to the $domain, $type, $item, for any $value
                "rm ${path_list}",
                # insert new node at the end of tree
                "set domain[last()+1] ${domain}",
                # assign values to the new node
                "set domain[last()]/type ${type}",
                "set domain[last()]/item ${item}",
                "set domain[last()]/value ${value}",
              ],
  }
}
