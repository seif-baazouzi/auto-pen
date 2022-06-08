<script>
  import Edit from "./icons/Edit.svelte"
  import Trash from "./icons/Trash.svelte"
  import FormPopup from "./FormPopup.svelte"
  import DeletePopup from "./DeletePopup.svelte"

  import { api } from "$lib/config.js"

  export let technologies = []

  let name = ""
  let hardening = ""
  let errors = {}
  
  let selectedTech

  const escape = (str) => str.replace(/\//g, "%2f")

  // add pop up
  let showAddPopup = false

  function showAddPopupFunc() {
    name = ""
    hardening = ""
    errors = {}

    showAddPopup = true
  }

  async function addCallback(event) {
    event.preventDefault()

    let res = await fetch(`${api}/technologies`, {
      method: "POST",
      headers: {
        "Content-type": "application/json",
        "X-Token": localStorage.getItem("admin-token")
      },
      body: JSON.stringify({ name, hardening })
    })
    res = await res.json()
    
    if(res.message === "invalid-token") {
      return goto("/admin/login")
    }

    if(res.message === "success") {
      technologies = [ ...technologies, { name, hardening } ]
      showAddPopup = false
    } else {
      errors = res
    }
  }

  // edit pop up
  let showEditPopup = false
  
  function showEditPopupFunc(tech) {
    name = tech.name
    hardening = tech.hardening
    errors = {}

    selectedTech = tech.name
    showEditPopup = true
  }

  async function editCallback(event) {
    event.preventDefault()

    let res = await fetch(`${api}/technologies/${escape(selectedTech)}`, {
      method: "PUT",
      headers: {
        "Content-type": "application/json",
        "X-Token": localStorage.getItem("admin-token")
      },
      body: JSON.stringify({ name, hardening })
    })
    res = await res.json()
    
    if(res.message === "invalid-token") {
      return goto("/admin/login")
    }

    if(res.message === "success") {
      technologies = technologies.map((tech) => {
        if(tech.name === selectedTech) {
          return { name, hardening }
        }

        return tech
      })
      showEditPopup = false
    } else {
      errors = res
    }
  }

  // delete pop up
  let showDeletePopup = false

  function showDeletePopupFunc(tech) {
    selectedTech = tech.name
    showDeletePopup = true
  }

  async function deleteCallback() {
    let res = await fetch(`${api}/technologies/${escape(selectedTech)}`, {
      method: "DELETE",
      headers: {
        "X-Token": localStorage.getItem("admin-token")
      }
    })
    res = await res.json()
    
    if(res.message === "invalid-token") {
      return goto("/admin/login")
    }

    technologies = technologies.filter(tech => tech.name !== selectedTech)
    showDeletePopup = false
  }
</script>

<div class="list-container">
  <div class="header">
    <h3>Technologies</h3>
    <div class="add" on:click={showAddPopupFunc}>+</div>
  </div> 
  {#if technologies.length == 0}
    <h2 class="msg">Click at the add button to add a new one.</h2>
  {:else} 
    <ul class="list">
      {#each technologies as tech}
        <li>
          <p>{tech.name}</p>
          <div class="icons">
            <div on:click={() => showEditPopupFunc(tech)}>
              <Edit size="1rem" color="green" />
            </div>
            <div on:click={() => showDeletePopupFunc(tech)}>
              <Trash size="1rem" color="var(--error)" />
            </div>
          </div>
        </li>
      {/each}
    </ul>
  {/if}   
</div>

{#if showAddPopup}
  <FormPopup
    title="Add technologie"
    bind:name={name}
    bind:hardening={hardening}
    errors={errors}
    closeCallback={() => showAddPopup = false}
    submitCallback={addCallback}
  />
{/if}

{#if showEditPopup}
  <FormPopup
    title="Edit technologie"
    bind:name={name}
    bind:hardening={hardening}
    errors={errors}
    closeCallback={() => showEditPopup = false}
    submitCallback={editCallback}
  />
{/if}

{#if showDeletePopup}
  <DeletePopup
    closeCallback={() => showDeletePopup = false}
    deleteCallback={deleteCallback}
  />
{/if}

<style>
  .msg {
    font-size: 1.5rem;
    padding: 2rem;
    margin-top: 1rem;
    text-align: center;
    background-color: #fff;
    box-shadow: var(--shadow);
  }

  .header {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  h3 {
    font-size: 1.2rem;
  }

  .add {
    color: #fff;
    line-height: .65;
    padding: .5rem;
    font-size: .9rem;
    font-weight: bold;
    border-radius: .5em;
    background-color: var(--primary);
    transition: background .3s ease-out;
    box-shadow: 0 .2rem .3rem rgba(0, 0, 0, .2);
    user-select: none;
    cursor: pointer;
  }

  .add:hover {
    background-color: #454545;
  }

  .list-container {
    width: 100%;
    max-width: 700px;
    margin: 0 auto;
  }

  .list {
    margin-top: .5rem;
  }

  li {
    width: 100%;
    padding: .5rem;
    margin: .25rem 0;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-radius: .25rem;    
    background-color: var(--white);
    box-shadow: var(--shadow);
  }

  li p {
    font-size: .75rem;
    color: var(--dark-gray);
  }

  li :global(svg) {
    cursor: pointer;
  }

  .icons {
    width: 2.5rem;
    display: flex;
    justify-content: space-between;
  }
</style>
