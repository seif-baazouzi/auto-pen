<script>
  import { onMount } from "svelte"
  import { goto } from "$app/navigation"
  import Clipboard from "svelte-clipboard"

  import Copy from "$lib/icons/Copy.svelte"
  import Loading from "$lib//Loading.svelte"
  import Reload from "$lib/icons/Reload.svelte"
  import UserNavBar from "$lib/UserNavBar.svelte"

  import { api } from "$lib/config.js"

  let apikey = null
  let showCopyPopup = false

  onMount(async () => {
    let res = await fetch(`${api}/user/apikey`, {
      headers: {
        "X-Token": localStorage.getItem("token")
      }
    })
    res = await res.json()
    
    if(res.message === "invalid-token") {
      return goto("/login")
    }

    apikey = res.apikey
  })

  async function reload() {
    let res = await fetch(`${api}/user/apikey`, {
      method: "PATCH",
      headers: {
        "X-Token": localStorage.getItem("token")
      }
    })
    res = await res.json()
    
    if(res.message === "invalid-token") {
      return goto("/login")
    }

    apikey = res.apikey
  }
</script>

<svelte:head>
  <title>Api key</title>
</svelte:head>

{#if apikey}
  <UserNavBar page="apikey" />
  <div class="container">
    <p>{apikey}</p>
    <Clipboard
      text={apikey}
      let:copy
      on:copy={() => {
        showCopyPopup = true
        setTimeout(() => showCopyPopup = false, 1000)
      }}>
      <div class="icon" on:click={copy}>
        <Copy color="var(--dark-gray)" size="1.5rem" />
        <div class={`copy-msg ${showCopyPopup ? "active": ""}`}>Copied</div>
      </div>
    </Clipboard>
    <div class="icon" on:click={reload}>
      <Reload color="var(--primary)" size="1.5rem" />
    </div>
  </div>
{:else}
  <Loading />
{/if}

<style>
  .container {
    width: calc(100% - 1rem);
    max-width: fit-content;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: .5rem;
    background-color: var(--white);
    position: absolute;
    top: 50%; left: 50%;
    transform: translate(-50%, -50%);
    border: .125rem solid var(--gray);
  }

  p {
    font-size: 1rem;
  }

  p, .icon {
    padding: .5rem;
  }

  .icon {
    cursor: pointer;
    position: relative;
    border-left: .125rem solid var(--gray);
  }

  .icon :global(svg) {
    opacity: .8;
  }

  .icon:hover :global(svg) {
    opacity: 1;
  }

  .icon :global(svg) {
    display: block;
  }

  .copy-msg {
    position: absolute;
    font-size: .75rem;
    font-weight: bold;
    border-radius: .5em;
    padding: .25em .75em;
    background-color: #fff;
    color: var(--dark-gray);
    box-shadow: var(--shadow);
    transform: translateX(-25%) translateY(50%);
    transition: .3s opacity ease-in-out;
    opacity: 0;
    z-index: 1;
  }

  .copy-msg.active {
    opacity: 1;
  }
</style>
