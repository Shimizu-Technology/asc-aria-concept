import { launchBrowser } from './chrome-launcher.mjs'

const url = process.env.CHECK_URL || 'http://127.0.0.1:5173'

const browser = await launchBrowser()
const page = await browser.newPage()
await page.setViewport({ width: 390, height: 1400, deviceScaleFactor: 1 })
await page.goto(url, { waitUntil: 'networkidle0' })
const metrics = await page.evaluate(() => {
  const doc = document.documentElement
  const body = document.body
  const all = [...document.querySelectorAll('*')]
    .map((el) => {
      const r = el.getBoundingClientRect()
      return { tag: el.tagName, cls: el.className, text: el.textContent?.trim().slice(0, 80), left: r.left, right: r.right, width: r.width }
    })
    .filter((x) => x.right > window.innerWidth + 1 || x.left < -1)
  return { innerWidth: window.innerWidth, scrollWidth: doc.scrollWidth, bodyScrollWidth: body.scrollWidth, offenders: all.slice(0, 30) }
})
console.log(JSON.stringify(metrics, null, 2))
await page.screenshot({ path: '/tmp/asc-aria-mobile-puppeteer.png', fullPage: false })
await browser.close()
