class Square

	@allSquares = []
	@maxSize = 50

	constructor: (options) ->
		@pos		= options.pos
		@mesh 		= new THREE.Mesh( new THREE.PlaneGeometry( 1, 1 ), new THREE.MeshBasicMaterial {color:0xFFFFFF} )
		@size 		= 0
		@active 	= true
		@callback	= options.callback

		@mesh.position.set @pos.x, @pos.y, 0
		@mesh.scale.set( @size, @size, @size )
		Square.allSquares.push this

	update: ->
		if @active
			# grow by 2 units
			@size += 2
			intersection = false
			# test new size against all other squares
			Square.allSquares.forEach (element)=>
				if element != this
					if @intersectionTest( element )
						intersection = true
			# if there was an intersection, shrink the size back and become inactive
			if intersection
				@size -= 2
				@active = false
			else if @size >= Square.maxSize
				@active = false
			# set the scale of the mesh
			@mesh.scale.set @size, @size, @size
		return @active

			

	intersectionTest: (otherSquare) ->
		c1 = @pos.x - @size/2 < otherSquare.pos.x + otherSquare.size/2
		c2 = @pos.x + @size/2 > otherSquare.pos.x - otherSquare.size/2
		c3 = @pos.y - @size/2 < otherSquare.pos.y + otherSquare.size/2
		c4 = @pos.y + @size/2 > otherSquare.pos.y - otherSquare.size/2
		return c1 and c2 and c3 and c4


class Scene

	constructor: (options) ->

		@WIDTH = if options.width != undefined then options.width else 500
		@HEIGHT = if options.height != undefined then options.height else 500

		@renderer = new THREE.WebGLRenderer({preserveDrawingBuffer:true, antialias:true})
		@renderer.setSize options.width, options.height
		$('#container').append @renderer.domElement

		@scene = new THREE.Scene()
		@camera = new THREE.OrthographicCamera( @WIDTH / -2, @WIDTH / 2, @HEIGHT / 2, @HEIGHT / - 2, - 5000, 5000 )
		@frameLength = 1000/60
		@time = 0
		@frames = []
		@saveFrames = false

	addSquare: =>
		if Square.allSquares.length < @maxSquares
			pos = new THREE.Vector2 Math.round(utils.random( -@WIDTH/2, @WIDTH/2 )), Math.round(utils.random( -@HEIGHT/2, @HEIGHT/2 ))
			square = new Square({pos:pos, callback:@addSquare})
			@scene.add square.mesh

	init: ->
		@maxSquares = 200
		# @addSquare()
		@update()

	updatePacking: =>
		allInactive = true
		badSquares = []
		Square.allSquares.forEach (element)->
			if element.update()
				allInactive = false
			else if element.size is 0
				badSquares.push element
		# get rid of bad squares
		badSquares.forEach (element)->
			element.mesh.parent.remove element.mesh
			Square.allSquares.splice Square.allSquares.indexOf( element ), 1

		if allInactive
			@addSquare()

	update: =>
		setTimeout (=>
			requestAnimationFrame( @update )
		), @frameLength

		TWEEN.update @time
		@time += @frameLength

		# updatePacking()
		

		@renderer.render @scene, @camera

		if @saveFrames
			frame = @renderer.domElement.toDataURL.replace /^data:image\/(png|jpg);base64,/, ""
			@frames.push frame