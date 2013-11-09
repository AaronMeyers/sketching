class LineManager
	constructor: (options = {}) ->
		@geometry 		= new THREE.Geometry()
		@maxLines		= if options.maxLines? then options.maxLines else 1000
		# fill geometry with verts
		for i in [0..@maxLines*2-1]
			@geometry.colors.push( new THREE.Color(0xFFFFFF) )
			@geometry.vertices.push( new THREE.Vector3( 0, 0, 0 ) )

		@mesh 			= new THREE.Line( @geometry, new THREE.LineBasicMaterial({color:0xFFFFFF,vertexColors:THREE.VertexColors}), THREE.LinePieces )
		@mesh.dynamic	= true
		@indexOffset	= 0

	randomize: ->
		for i in [0..@maxLines-1]
			color = new THREE.Color().setRGB utils.random(), utils.random(), utils.random()
			@geometry.vertices[i*2+0].set utils.random(-100,100), utils.random(-100,100), 0
			@geometry.vertices[i*2+1].set utils.random(-100,100), utils.random(-100,100), 0
			@geometry.colors[i*2+0].set color
			@geometry.colors[i*2+1].set color
		@geometry.verticesNeedUpdate = true

	addLine: ( x1, y1, x2, y2, r = 1, g = 1, b = 1 )->
		if @indexOffset == @maxLines
			return

		@geometry.vertices[@indexOffset*2+0].set x1, y1, 0
		@geometry.vertices[@indexOffset*2+0].set x2, y2, 0
		@geometry.colors[@indexOffset*2+0].setRGB r, g, b
		@geometry.colors[@indexOffset*2+1].setRGB r, g, b

		@indexOffset++

	clear: ->
		@indexOffset = 0

	update: ->
		if ( @indexOffset < @maxLines )
			for i in [@indexOffset..@maxLines-1]
				# console.log( i + ', ' + @maxLines-1 )
				@geometry.vertices[i*2+0].set 0, 0, 0
				@geometry.vertices[i*2+1].set 0, 0, 0
		@geometry.verticesNeedUpdate = true