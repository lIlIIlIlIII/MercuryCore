// Fun Unicode art 'logo', inspired by HybridOS

import color from "picocolors"

const logo = `
  ██▙    ▟██ ${color.blue("Started")}
  ███▙  ▟███ ▟████▙ ▗████▛▗█████▌██   ██ ▟████▙▝█▙    ▗█▛
  ██▝█▙▟█▘██▐█▌  ▐█▌██▘   ██▘    ██   ██▐█▛     ▝█▙  ▗█▛
  ██ ▝██▘ ██▐█████▛ ██    ██     ██   ██▐█▌      ▝█▙▗█▛
  ██      ██▐█▌     ██    ██▖    ██▖ ▗██▐█▌       ▝██▛
  ▛▀      ▜█ ▜████▛ ██    ▝█████▙▝█████▘▐█▌       ▗█▛
  ▗██████▛                                       ▗█▛
  ██▘    ▗█████▖ ▟████▛▗█████▖                  ▗█▛
  ██     ██   ██▐█▛    ██   ██ ${color.blue("Self-hostable MMO")}
  ██     ██   ██▐█▌    ██████▘ ${color.blue("game creation platform:")}
  ██▖    ██   ██▐█▌    ██      ${color.green("Build-your-own-Roblox")}
  ▝█████▙▝█████▘▐█▌    ▝█████▘
`

let done = false

export default () => {
	if (done) return
	done = true
	console.log(color.magenta(logo))
}
