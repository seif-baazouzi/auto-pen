<script>
  import Input from "./Input.svelte"

  import { api } from "$lib/config.js"

  let oldpwd = ""
  let newpwd = ""
  let errors = {}

  async function change(event) {
    event.preventDefault()

    let res = await fetch(`${api}/admin/settings/update-password`, {
      method: "PATCH",
      headers: {
        "Content-type": "application/json",
        "X-Token": localStorage.getItem("admin-token")
      },
      body: JSON.stringify({ oldpwd, newpwd })
    })
    res = await res.json()
    
    if(res.message === "invalid-token") {
      return goto("/admin/login")
    }

    if(res.message === "success") {
      oldpwd = ""
      newpwd = ""
      errors = {}
    } else {
      errors = res
    }
  }
</script>

<div class="container">
  <h3>Update your password</h3>
  <form on:submit={change}>
    <Input
      label="Old password"
      bind:value={oldpwd}
      error={errors.oldpwd}
      type="password"
    />
    <Input
      label="New password"
      bind:value={newpwd}
      error={errors.newpwd}
      type="password"
    />
    <button>Update</button>
  </form>
</div>

<style>
  h3 {
    margin-bottom: 2rem;
  }

  button {
    font-weight: bold;
    color: var(--white);
    display: block;
    margin-left: auto;
    background-color: var(--primary);
  }

  button:hover {
    background-color: var(--dark-gray);
  }
</style>
