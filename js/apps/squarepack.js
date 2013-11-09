// Generated by CoffeeScript 1.6.3
var Scene, Square,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Square = (function() {
  Square.allSquares = [];

  Square.maxSize = 50;

  function Square(options) {
    this.pos = options.pos;
    this.mesh = new THREE.Mesh(new THREE.PlaneGeometry(1, 1), new THREE.MeshBasicMaterial({
      color: 0xFFFFFF
    }));
    this.size = 0;
    this.active = true;
    this.callback = options.callback;
    this.mesh.position.set(this.pos.x, this.pos.y, 0);
    this.mesh.scale.set(this.size, this.size, this.size);
    Square.allSquares.push(this);
  }

  Square.prototype.update = function() {
    var intersection,
      _this = this;
    if (this.active) {
      this.size += 2;
      intersection = false;
      Square.allSquares.forEach(function(element) {
        if (element !== _this) {
          if (_this.intersectionTest(element)) {
            return intersection = true;
          }
        }
      });
      if (intersection) {
        this.size -= 2;
        this.active = false;
      } else if (this.size >= Square.maxSize) {
        this.active = false;
      }
      this.mesh.scale.set(this.size, this.size, this.size);
    }
    return this.active;
  };

  Square.prototype.intersectionTest = function(otherSquare) {
    var c1, c2, c3, c4;
    c1 = this.pos.x - this.size / 2 < otherSquare.pos.x + otherSquare.size / 2;
    c2 = this.pos.x + this.size / 2 > otherSquare.pos.x - otherSquare.size / 2;
    c3 = this.pos.y - this.size / 2 < otherSquare.pos.y + otherSquare.size / 2;
    c4 = this.pos.y + this.size / 2 > otherSquare.pos.y - otherSquare.size / 2;
    return c1 && c2 && c3 && c4;
  };

  return Square;

})();

Scene = (function() {
  function Scene(options) {
    this.update = __bind(this.update, this);
    this.updatePacking = __bind(this.updatePacking, this);
    this.addSquare = __bind(this.addSquare, this);
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
    this.frameLength = 1000 / 60;
    this.time = 0;
    this.frames = [];
    this.saveFrames = false;
  }

  Scene.prototype.addSquare = function() {
    var pos, square;
    if (Square.allSquares.length < this.maxSquares) {
      pos = new THREE.Vector2(Math.round(utils.random(-this.WIDTH / 2, this.WIDTH / 2)), Math.round(utils.random(-this.HEIGHT / 2, this.HEIGHT / 2)));
      square = new Square({
        pos: pos,
        callback: this.addSquare
      });
      return this.scene.add(square.mesh);
    }
  };

  Scene.prototype.init = function() {
    this.maxSquares = 200;
    return this.update();
  };

  Scene.prototype.updatePacking = function() {
    var allInactive, badSquares;
    allInactive = true;
    badSquares = [];
    Square.allSquares.forEach(function(element) {
      if (element.update()) {
        return allInactive = false;
      } else if (element.size === 0) {
        return badSquares.push(element);
      }
    });
    badSquares.forEach(function(element) {
      element.mesh.parent.remove(element.mesh);
      return Square.allSquares.splice(Square.allSquares.indexOf(element), 1);
    });
    if (allInactive) {
      return this.addSquare();
    }
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
      frame = this.renderer.domElement.toDataURL.replace(/^data:image\/(png|jpg);base64,/, "");
      return this.frames.push(frame);
    }
  };

  return Scene;

})();