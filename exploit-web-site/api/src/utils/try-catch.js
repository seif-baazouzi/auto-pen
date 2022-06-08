function trycatch(req, res, routeCallBack) {
  try {
    routeCallBack()
  } catch(err) {
    log.error(err)
    res.status(500).json({ message: "server-error" })
  }
}

module.exports = trycatch
