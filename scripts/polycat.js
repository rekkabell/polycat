'use strict'

function Polycat () {
  this.id = 'polycat'
  this.el = document.createElement('canvas')

  this.assets = new Assets(this)
  this.target = { x: 0, y: 0 }
  this.focus = { x: 0, y: 0 }
  this.isReady = false
  this.f = 0

  this.install = function (host = document.body) {
    host.appendChild(this.el)
    this.setup()
  }

  this.setup = function () {
    this.el.width = 600
    this.el.height = 600
    this.el.style.width = '300px'
    this.el.style.height = '300px'
    this.context = this.el.getContext('2d')
    this.assets.setup(['body', 'eye', 'head', 'pupil', 'shadow'])
  }

  this.start = function () {
    this.isReady = true
    polycat.look()
  }

  this.onMove = function (e) {
    polycat.target = { x: -(e.screenX / window.innerWidth) + 0.5, y: -(e.screenY / window.innerHeight) + 0.5 }
  }

  this.clear = function () {
    if (!this.isReady) { return }
    this.context.clearRect(0, 0, this.el.width, this.el.height)
  }

  this.look = function () {
    const rate = 5
    if (Math.abs(polycat.focus.x - polycat.target.x) > 0.0001) {
      polycat.focus.x += polycat.target.x > polycat.focus.x ? (Math.abs(polycat.target.x - polycat.focus.x) / rate) : (Math.abs(polycat.target.x - polycat.focus.x) / rate) * -1
    }
    if (Math.abs(polycat.focus.y - polycat.target.y) > 0.0001) {
      polycat.focus.y += polycat.target.y > polycat.focus.y ? (Math.abs(polycat.target.y - polycat.focus.y) / rate) : (Math.abs(polycat.target.y - polycat.focus.y) / rate) * -1
    }
    polycat.draw()
    window.requestAnimationFrame(polycat.look)
  }

  this.draw = function () {
    if (!this.isReady) { return }

    this.clear()

    const bob = Math.sin(-this.f / 10) * Math.PI / 4
    const range = 100
    const offset = { x: range * this.focus.x * -1, y: range * this.focus.y * -1 }
    // body
    const bodyRect = { x: 0, y: 0, w: 600, h: 600 }
    this.context.drawImage(this.assets.get('shadow'), bodyRect.x, bodyRect.y, bodyRect.w, bodyRect.h)
    this.context.drawImage(this.assets.get('body'), bodyRect.x, bodyRect.y, bodyRect.w, bodyRect.h)
    // Head
    const headRect = { x: offset.x * 0.25, y: (offset.y * 0.1) + bob, w: 600, h: 600 }
    this.context.drawImage(this.assets.get('eye'), headRect.x, headRect.y, headRect.w, headRect.h)
    const pupilRect = { x: offset.x * 0.7, y: (offset.y * 0.25) + (bob * 0.75), w: 600, h: 600 }
    this.context.drawImage(this.assets.get('pupil'), pupilRect.x, pupilRect.y, pupilRect.w, pupilRect.h)
    this.context.drawImage(this.assets.get('head'), headRect.x, headRect.y, headRect.w, headRect.h)

    this.f += 1
  }

  document.addEventListener('mousemove', function (e) { polycat.onMove(e) }, false)
}
