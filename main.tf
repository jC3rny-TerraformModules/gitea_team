
locals {
  gitea_team = {
    for k, v in var.gitea_team : k => {
      name        = coalesce(v.name, k)
      description = try(v.description, "")
      #
      include_all_repositories = coalesce(v.include_all_repositories, false)
      can_create_repos         = coalesce(v.can_create_repos, false)
      #
      permission = v.permission
      #
      units = try(v.units, "")
      #
      members = [for obj in coalesce(v.members, []) : data.gitea_user.user[obj].username]
      #
      repositories = [for obj in coalesce(v.repositories, []) : data.gitea_repo.repo[obj].name]
    }
  }
  #
  gitea_users = { for k, v in distinct(flatten([for obj in var.gitea_team : obj.members if obj.members != null])) : v => {} }
  #
  gitea_repositories = { for k, v in distinct(flatten([for obj in var.gitea_team : obj.repositories if obj.repositories != null])) : v => {} }
}


data "gitea_org" "this" {
  name = var.gitea_org_name
}


data "gitea_user" "user" {
  for_each = local.gitea_users
  #
  username = each.key
  #
  depends_on = [
    data.gitea_org.this
  ]
}

data "gitea_repo" "repo" {
  for_each = local.gitea_repositories
  #
  name     = each.key
  username = data.gitea_org.this.name
  #
  depends_on = [
    data.gitea_org.this
  ]
}

resource "gitea_team" "aux" {
  for_each = { for k, v in local.gitea_team : k => v }
  #
  name        = each.value.name
  description = each.value.description
  #
  organisation = data.gitea_org.this.name
  #
  include_all_repositories = each.value.include_all_repositories
  can_create_repos         = each.value.can_create_repos
  #
  permission = each.value.permission
  #
  units = each.value.units
  #
  members = each.value.members
  #
  repositories = each.value.repositories
  #
  depends_on = [
    data.gitea_org.this,
    data.gitea_user.user,
    data.gitea_repo.repo,
  ]
}
