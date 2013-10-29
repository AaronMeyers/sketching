var utils = {

  unescape: function(string) {
    return (''+string).replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&#x27;/g, "'").replace(/&#x2F;/g,'/');
  },

  sign: function(v) {
    return v >= 0 ? 1 : -1;
  },

  lerp: function(a, b, t) {
    return (b - a) * t + a;
  },

  map: function(v, i1, i2, o1, o2) {
    return o1 + (o2 - o1) * ((v - i1) / (i2 - i1));
  },

  cmap: function(v, i1, i2, o1, o2) {
    return utils.clamp(o1 + (o2 - o1) * (v - i1) / (i2 - i1), o1, o2);
  },

  wrap: function(value, rangeSize) {
    while (value < 0) {
      value += rangeSize;
    }
    return value % rangeSize;
  },

  cap: function(v, maxMagnitude) {
    if (Math.abs(v) > maxMagnitude) {
      return utils.sign(v) * maxMagnitude;
    } else {
      return v;
    }
  },

  dist: function(x1, y1, x2, y2) {
    return Math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
  },

  clamp: function(v, min, max) {
    return Math.max(Math.min(v, max), min);
  },

  roundToDecimal: function(value, decimals) {
    var tenTo = Math.pow(10, decimals);
    return Math.round(value * tenTo) / tenTo;
  },

  randomSign: function() {
    return (Math.random()>.5) ? -1.0 : 1.0;
  },

  random: function() {

    if (arguments.length == 0) {

      return Math.random();

    } else if (arguments.length == 1) {

      if (typeof arguments[0] == 'number') {

        return Math.random() * arguments[0];

      } else if (typeof arguments[0] == 'array' || Array.isArray( arguments[0] ) ) {
        
        return arguments[0][Math.floor(utils.random(arguments[0].length))];

      }

    } else if (arguments.length == 2) {

      return utils.lerp(arguments[0], arguments[1], Math.random());

    }

  },

  clone: function(obj) {
    if (obj == null || typeof obj != 'object')
      return obj;
    var temp = obj.constructor(); // changed
    for (var key in obj)
      temp[key] = clone(obj[key]);
    return temp;
  },

  bezier: function(a, b, c, d, t) {
    var t1 = 1.0 - t;
    return a * t1 * t1 * t1 + 3 * b * t * t1 * t1 + 3 * c * t * t * t1 +
        d * t * t * t;
  },

  commaify: function(s, d) {
    if (!d) {
      d = 3;
    }
    var s = s.toString().split('').reverse().join('');
    var r = '';
    var j = 0;
    for (var i = 0; i < s.length; i++) {
      var l = s.charAt(i);
      if (j > d - 1) {
        j = 0;
        r += ',';
      } else {
        j++;
      }
      r += l;
    }
    return r.split('').reverse().join('');
  },

  makeUnselectable: function(elem) {
    if (elem == undefined || elem.style == undefined) return;
    elem.onselectstart = function() {
      return false;
    };
    elem.style.MozUserSelect = 'none';
    elem.style.KhtmlUserSelect = 'none';
    elem.unselectable = 'on';

    var kids = elem.childNodes;
    var l = kids.length;
    for (var i = 0; i < l; i++) {
      this.makeUnselectable(kids[i]);
    }

  },

  makeSelectable: function(elem) {
    if (elem == undefined || elem.style == undefined) return;
    elem.onselectstart = function() {};
    elem.style.MozUserSelect = 'auto';
    elem.style.KhtmlUserSelect = 'auto';
    elem.unselectable = 'off';
    var kids = elem.childNodes;
    var l = kids.length;
    for (var i = 0; i < l; i++) {
      this.makeSelectable(kids[i]);
    }
  },

  shuffle: function(o) { //v1.0
    for (var j, x, i = o.length; i; j = parseInt(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
    return o;
  }

};