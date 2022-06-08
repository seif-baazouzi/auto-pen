<script>
  import { goto } from "$app/navigation"

  import Input from "$lib/Input.svelte"
  import FormLayout from "$lib/FormLayout.svelte"

  import { api } from "$lib/config.js"

  let username = ""
  let password = ""
  let errors = {}

  async function login(e) {
    e.preventDefault()
    
    const res = await fetch(`${api}/admin/login`, {
      method: 'POST',
      headers: {
        "Content-type": "application/json"
      },
      body: JSON.stringify({ username, password })
    })
    const data = await res.json()
    
    if(data.token) {
      localStorage.setItem("admin-token", data.token)      
      goto("/admin")
    } else {
      errors = data
    }
  }
</script>

<svelte:head>
  <title>Login</title>
</svelte:head>

<FormLayout
  title="Welcome"
  button="Login"
  submit={login}
  >
  <Input
    label="Username"
    bind:value={username}
    error={errors.username}
  />
  <Input
    label="Password"
    bind:value={password}
    error={errors.password}
    type="password"
  />
</FormLayout>
