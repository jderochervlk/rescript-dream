import express from 'express'

let app = express()

app.use("/", (req, res, next) => {
    res.appendHeader()
})