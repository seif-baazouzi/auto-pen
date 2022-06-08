// set the year of the copyright label

const date = new Date()
year.innerText = date.getFullYear()

// toggle navbar

function toggleNavbar() {
  const heroSectionHeight = hero.offsetHeight
  const scrollTop = window.pageYOffset || document.documentElement.scrollTop;

  if(heroSectionHeight - 200 > scrollTop) {
    nav.classList.add("active")
  } else {
    nav.classList.remove("active")
  }
}

toggleNavbar()
document.onscroll = toggleNavbar

// toggle burger and links

const links = document.querySelector("nav ul")

burger.addEventListener("click", () => {
  links.classList.toggle("hide")
})

document.querySelectorAll("nav ul a").forEach(link => {
  link.addEventListener("click", () => links.classList.add("hide"))
})
