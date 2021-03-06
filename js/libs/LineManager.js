// Generated by CoffeeScript 1.6.3
var LineManager;

LineManager = (function() {
  function LineManager(options) {
    var i, _i, _ref;
    if (options == null) {
      options = {};
    }
    this.geometry = new THREE.Geometry();
    this.maxLines = options.maxLines != null ? options.maxLines : 1000;
    for (i = _i = 0, _ref = this.maxLines * 2 - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
      this.geometry.colors.push(new THREE.Color(0xFFFFFF));
      this.geometry.vertices.push(new THREE.Vector3(0, 0, 0));
    }
    this.mesh = new THREE.Line(this.geometry, new THREE.LineBasicMaterial({
      color: 0xFFFFFF,
      vertexColors: THREE.VertexColors
    }), THREE.LinePieces);
    this.mesh.dynamic = true;
    this.indexOffset = 0;
  }

  LineManager.prototype.randomize = function() {
    var color, i, _i, _ref;
    for (i = _i = 0, _ref = this.maxLines - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
      color = new THREE.Color().setRGB(utils.random(), utils.random(), utils.random());
      this.geometry.vertices[i * 2 + 0].set(utils.random(-100, 100), utils.random(-100, 100), 0);
      this.geometry.vertices[i * 2 + 1].set(utils.random(-100, 100), utils.random(-100, 100), 0);
      this.geometry.colors[i * 2 + 0].set(color);
      this.geometry.colors[i * 2 + 1].set(color);
    }
    return this.geometry.verticesNeedUpdate = true;
  };

  LineManager.prototype.addLine = function(x1, y1, x2, y2, r, g, b) {
    if (r == null) {
      r = 1;
    }
    if (g == null) {
      g = 1;
    }
    if (b == null) {
      b = 1;
    }
    if (this.indexOffset === this.maxLines) {
      return;
    }
    this.geometry.vertices[this.indexOffset * 2 + 0].set(x1, y1, 0);
    this.geometry.vertices[this.indexOffset * 2 + 0].set(x2, y2, 0);
    this.geometry.colors[this.indexOffset * 2 + 0].setRGB(r, g, b);
    this.geometry.colors[this.indexOffset * 2 + 1].setRGB(r, g, b);
    return this.indexOffset++;
  };

  LineManager.prototype.clear = function() {
    return this.indexOffset = 0;
  };

  LineManager.prototype.update = function() {
    var i, _i, _ref, _ref1;
    if (this.indexOffset < this.maxLines) {
      for (i = _i = _ref = this.indexOffset, _ref1 = this.maxLines - 1; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; i = _ref <= _ref1 ? ++_i : --_i) {
        this.geometry.vertices[i * 2 + 0].set(0, 0, 0);
        this.geometry.vertices[i * 2 + 1].set(0, 0, 0);
      }
    }
    return this.geometry.verticesNeedUpdate = true;
  };

  return LineManager;

})();
