<script>
  import Input from "./Input.svelte"

  import { api } from "$lib/config.js"

  let username = ""
  let password = ""
  let errors = {}

  async function change(event) {
    event.preventDefault()

    let res = await fetch(`${api}/admin/settings/update-username`, {
      method: "PATCH",
      headers: {
        "Content-type": "application/json",
        "X-Token": localStorage.getItem("admin-token")
      },
      body: JSON.stringify({ username, password })
    })
    res = await res.json()
    
    if(res.message === "invalid-token") {
      return goto("/admin/login")
    }

    if(res.token) {
      localStorage.setItem("admin-token", res.token)
      username = ""
      password = ""
      errors = {}
    } else {
      errors = res
    }
  }
</script>

<div class="container">
  <h3>Update your username</h3>
  <form on:submit={change}>
    <Input
      label="New Username"
      bind:value={username}
      error={errors.username}
    />
    <Input
      label="Password"
      bind:value={password}
      error={errors.password}
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
