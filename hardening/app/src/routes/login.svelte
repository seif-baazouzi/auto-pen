<script>
  import { goto } from "$app/navigation"

  import Input from "$lib/Input.svelte"
  import FormLayout from "$lib/FormLayout.svelte"

  import { api } from "$lib/config.js"

  let email = ""
  let password = ""
  let errors = {}

  async function login(e) {
    e.preventDefault()
    
    let res = await fetch(`${api}/user/login`, {
      method: 'POST',
      headers: {
        "Content-type": "application/json"
      },
      body: JSON.stringify({ email, password })
    })
    res = await res.json()

    if(res.token) {
      localStorage.setItem("token", res.token)      
      goto("/")
    } else {
      errors = res
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
  link={{
    prefix: "Don't have an account?",
    href: "/signup",
    content: "Create account"
  }}
  >
  <Input
    label="Email"
    bind:value={email}
    error={errors.email}
  />
  <Input
    label="Password"
    bind:value={password}
    error={errors.password}
    type="password"
  />
</FormLayout>
