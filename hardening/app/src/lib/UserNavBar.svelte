<script>
  import NavBar from "./NavBar.svelte"
  import { goto } from "$app/navigation"

  export let page

  const links = [
    { href: "/", page: "home", content: "Home" },
    { href: "/statistics", page: "statistics", content: "Statistics" },
    { href: "/apikey", page: "apikey", content: "Apikey" },
  ]

  function logout() {
    localStorage.removeItem("token")
    goto("/login")
  }
</script>

<NavBar
  page={page}
  home="/"
  links={links}
  logoutCallBack={logout}
/>
