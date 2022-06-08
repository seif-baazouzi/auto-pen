<script>
  import { onMount } from "svelte"
  import { goto } from "$app/navigation"

  import Loading from "../lib/Loading.svelte"
  import UserNavBar from "../lib/UserNavBar.svelte"

  import { api } from "$lib/config.js"

  let logs = null
  let pages = null
  let selectedPage = null
  
  onMount(getLogs)
  
  async function getLogs() {
    let page = 1
    const urlParams = new URLSearchParams(window.location.search);
    if(urlParams.has("page")) page = parseInt(urlParams.get("page"))

    let res = await fetch(`${api}/user/logs?page=${page}`, {
      headers: {
        "X-Token": localStorage.getItem("token")
      }
    })
    res = await res.json()

    if(res.message === "invalid-token") {
      return goto("/login")
    }

    logs = res.data
    
    if(res.pages > 1) {
      selectedPage = page
      pages = getPagesList(res.pages, selectedPage)
    } else {
      pages = null
    }
  }

  function getPagesList(pages, selectedPage) {
    const pagesList = []

    if(pages <= 7) {
      for(let i=1; i<=pages; i++) {
        pagesList.push(i)
      }
    } else {
      pagesList.push(1)

      if(selectedPage < 3) {
        pagesList.push(2)
        pagesList.push(3)
        pagesList.push(4)
        pagesList.push(5)
        pagesList.push(null)
      } else if (selectedPage > pages - 3) {
        pagesList.push(null)
        for(let i=pages-4; i<pages; i++) pagesList.push(i)
      } else {
        pagesList.push(null)
        for(let i=selectedPage-1; i<=selectedPage+1; i++) pagesList.push(i)
        pagesList.push(null)
      }
      
      pagesList.push(pages)
    }

    return pagesList
  }

  function formatDate(rawDate) {
    const date = new Date(rawDate)
    return date.toLocaleString()
  }

  async function getLogsPage(page) {
    console.log(page);
    await goto(`?page=${page}`)
    await getLogs()
  }
</script>

<svelte:head>
  <title>Home</title>
</svelte:head>

{#if logs != null}
  <UserNavBar page="home" />
  <div class="container">
    {#if logs.length == 0}
      <h1 class="msg">There is no logs yet!</h1>
    {:else}
      <div class="table">
        <table>
          <thead>
            <th>ID</th>
            <th>Query</th>
            <th>Date</th>
          </thead>
          <tbody>
            {#each logs as log}
              <tr>
                <td>{log.logID}</td>
                <td>{log.query}</td>
                <td>{formatDate(log.logDate)}</td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
      {#if pages}
        <div class="pages">
          <button
            on:click={() => getLogsPage(selectedPage-1)}
            disabled={selectedPage === 1}
            style="margin-right: .25rem"
            >prev
          </button>
          {#each pages as page}
            {#if page != null}
              <button on:click={() => getLogsPage(page)} class={page === selectedPage ? "active": ""}>{page}</button>
            {:else}
              <button>...</button>
            {/if}
            {/each}
            <button
              on:click={() => getLogsPage(selectedPage+1)}
              disabled={selectedPage === pages.slice(-1)[0]}
              style="margin-left: .25rem"
              >next
            </button>
        </div>
      {/if}
    {/if}
  </div>
{:else}
  <Loading />
{/if}

<style>
  .container {
    width: 100%;
    max-width: 1024px;
    margin: 0 auto;
    padding: 1rem;
  }

  h1.msg {
    font-size: 2rem;
    text-align: center;
    padding: 2rem 1rem;
  }

  .table {
    width: 100%;
    background-color: var(--white);
    overflow-x: auto;
    border-radius: .125rem;
    box-shadow: var(--shadow);
  }

  .table table {
    width: 100%;
    border-collapse: collapse;
  }

  .table table thead {
    background-color: var(--gray);
  }
  
  .table table th {
    text-align: left;
    font-size: .75rem;
    color: var(--dark-gray);
  }

  .table table :is(td, th) {
    padding: .5rem 1rem;
  } 

  .table table tbody tr:hover {
    background-color: var(--bg);
  }

  .table table td {
    font-size: .75rem;
    padding: .5rem 1rem;
    border-top: .075rem solid #dee2e6;
    transition: background .3s ease-in;
  } 

  .table table td:first-child {
    width: 4rem;
  }

  .table table td:last-child {
    width: 12rem;
  }
  
  .pages {
    width: fit-content;
    margin: 1rem auto;
    display: flex;
    align-items: center;
    overflow: hidden;
    border-radius: .25rem;
  }

  .pages button {
    font-size: .6rem;
    border-radius: 0;
    font-weight: bold;
    color: var(--dark-gray);
  }

  .pages button.active {
    color: var(--white);
    background-color: var(--primary);
  }

  .pages button.active:hover {
    background-color: var(--dark-gray);
  }
</style>