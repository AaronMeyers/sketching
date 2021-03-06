// Generated by CoffeeScript 1.6.3
var Scene,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Scene = (function() {
  function Scene(options) {
    this.update = __bind(this.update, this);
    this.WIDTH = options.width !== void 0 ? options.width : 500;
    this.HEIGHT = options.height !== void 0 ? options.height : 500;
    this.renderer = new THREE.WebGLRenderer({
      preserveDrawingBuffer: true,
      antialias: true
    });
    this.renderer.setSize(options.width, options.height);
    $('#container').append(this.renderer.domElement);
    this.scene = new THREE.Scene();
    this.camera = new THREE.OrthographicCamera(this.WIDTH / -2, this.WIDTH / 2, this.HEIGHT / 2, this.HEIGHT / -2, -5000, 5000);
    this.frameLength = 1000 / 30;
    this.time = 0;
    this.frames = [];
    this.saveFrames = false;
  }

  Scene.prototype.init = function() {
    return this.update();
  };

  Scene.prototype.update = function() {
    var frame,
      _this = this;
    setTimeout((function() {
      return requestAnimationFrame(_this.update);
    }), this.frameLength);
    TWEEN.update(this.time);
    this.time += this.frameLength;
    this.renderer.render(this.scene, this.camera);
    if (this.saveFrames) {
      frame = this.renderer.domElement.toDataURL().replace(/^data:image\/(png|jpg);base64,/, "");
      return this.frames.push(frame);
    }
  };

  return Scene;

})();
