<script>
  import { goto } from "$app/navigation"

  import Input from "$lib/Input.svelte"
  import FormLayout from "$lib/FormLayout.svelte"

  import { api } from "$lib/config.js"

  let email = ""
  let password = ""
  let errors = {}

  async function signup(e) {
    e.preventDefault()
    
    let res = await fetch(`${api}/user/signup`, {
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
  <title>Signup</title>
</svelte:head>

<FormLayout
  title="Join us"
  button="Signup"
  submit={signup}
  link={{
    prefix: "Have an account?",
    href: "/login",
    content: "Login"
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
