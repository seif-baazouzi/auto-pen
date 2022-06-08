<script>
  import NavBar from "./NavBar.svelte"
  import { goto } from "$app/navigation"

  export let page

  const links = [
    { href: "/admin", page: "home", content: "Home" },
    { href: "/admin/settings", page: "settings", content: "Settings" },
  ]

  function logout() {
    localStorage.removeItem("admin-token")
    goto("/admin/login")
  }
</script>

<NavBar
  page={page}
  home="/admin"
  links={links}
  logoutCallBack={logout}
/>
