<script>
  import { onMount } from "svelte"
  import { goto } from "$app/navigation"

  import List from "$lib/List.svelte"
  import Loading from "$lib/Loading.svelte"
  import AdminNavBar from "../../lib/AdminNavBar.svelte"

  import { api } from "$lib/config.js"

  let technologies = null
  onMount(async () => {
    let res = await fetch(`${api}/technologies`, {
      headers: {
        "X-Token": localStorage.getItem("admin-token")
      }
    })
    res = await res.json()
    
    if(res.message === "invalid-token") {
      return goto("/admin/login")
    }

    technologies = res.data
  })
</script>

<svelte:head>
  <title>Dashboard</title>
</svelte:head>

{#if technologies != null}
  <AdminNavBar page="home" />
  <div class="container">
    <List technologies={technologies} />
  </div>
{:else}
  <Loading />
{/if}

<style>
  .container {
    padding: 1rem;
  }
</style>
