import express from 'express'
import { adminJs, router } from './adminjs-config.js'

const app = express()
const PORT = 5001

// تفعيل ملفات الـ Static (اختياري، تحسباً لأي صور)
app.use(express.static('public'))

// استخدام الراوتر
app.use(adminJs.options.rootPath, router)

app.listen(PORT, () => {
  console.log(`🚀 AdminJS running at http://localhost:${PORT}${adminJs.options.rootPath}`)
})