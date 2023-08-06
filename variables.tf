
# gitea_org
variable "gitea_org_name" {
  type = string
  #
  default = ""
}

# gitea_team
variable "gitea_team" {
  type = map(object({
    name        = optional(string)
    description = optional(string)
    #
    include_all_repositories = optional(bool)
    can_create_repos         = optional(bool)
    #
    permission = string
    #
    units = optional(string)
    #
    members = optional(list(string))
    #
    repositories = optional(list(string))
  }))
  #
  default = {}
}
