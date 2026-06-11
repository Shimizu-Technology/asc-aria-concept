import puppeteer from 'puppeteer-core'

const url = process.env.CHECK_URL || 'http://127.0.0.1:5173'

const browser = await puppeteer.launch({
  executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  headless: true,
  args: ['--no-sandbox'],
})
const page = await browser.newPage()
await page.setViewport({ width: 1440, height: 1100, deviceScaleFactor: 1 })
await page.goto(url, { waitUntil: 'networkidle0' })
const metrics = await page.evaluate(() => {
  const offenders = [...document.querySelectorAll('*')]
    .map((el) => {
      const r = el.getBoundingClientRect()
      return { tag: el.tagName, cls: el.className, text: el.textContent?.trim().slice(0, 80), left: r.left, right: r.right, width: r.width }
    })
    .filter((x) => x.right > window.innerWidth + 1 || x.left < -1)
  return { innerWidth: window.innerWidth, scrollWidth: document.documentElement.scrollWidth, offenders: offenders.slice(0, 20) }
})
console.log(JSON.stringify(metrics, null, 2))
await page.screenshot({ path: '/tmp/asc-aria-desktop-puppeteer.png', fullPage: false })
await browser.close()
