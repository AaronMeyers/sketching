class Scene

	constructor: (options) ->

		@WIDTH = if options.width != undefined then options.width else 500
		@HEIGHT = if options.height != undefined then options.height else 500

		@renderer = new THREE.WebGLRenderer({preserveDrawingBuffer:true, antialias:true})
		@renderer.setSize options.width, options.height
		$('#container').append @renderer.domElement

		@scene = new THREE.Scene()
		@camera = new THREE.OrthographicCamera( @WIDTH / -2, @WIDTH / 2, @HEIGHT / 2, @HEIGHT / - 2, - 5000, 5000 )
		@frameLength = 1000/30
		@time = 0
		@frames = []
		@saveFrames = false
		@gui = new dat.GUI {height: 1000, width:300}
		@circleDistanceScale = 1.15
		@gui.add( this, 'circleDistanceScale', 1, 2 ).onChange ( value ) =>
			i = 0
			while i < @circle.children.length
				aCircle = @circle.children[i].children[0]
				aCircle.position.x = aCircle.geometry.radius * value
				i++

	init: ->

		circleGeom		= new THREE.CircleGeometry @WIDTH/2, 60
		circleMaterial	= new THREE.MeshBasicMaterial {color:0xFFFFFF}
		@circle 		= new THREE.Mesh circleGeom, circleMaterial

		# make three circles
		i = 0
		numCircles = 3
		while i < numCircles
			aCircleGeom			= new THREE.CircleGeometry @circle.geometry.radius * .465, 60
			aCircleMaterial		= new THREE.MeshBasicMaterial {color:0x000000}

			aNode				= new THREE.Object3D
			aCircle 			= new THREE.Mesh aCircleGeom, aCircleMaterial
			aCircle.position.z = 1
			aCircle.position.x = aCircle.geometry.radius * @circleDistanceScale
			aNode.rotation.z = (i / numCircles) * Math.PI * 2
			# aCircle.position.x = aCircle.geometry.radius * 2 * Math.sin( i / numCircles * Math.PI * 2 )
			# aCircle.position.y = aCircle.geometry.radius * 2 * Math.cos( i / numCircles * Math.PI * 2 )
			aNode.add aCircle
			@circle.add aNode
			i++




		@scene.add @circle

		@update()

	update: =>
		setTimeout (=>
			requestAnimationFrame( @update )
		), @frameLength

		TWEEN.update @time
		@time += @frameLength
		@renderer.render @scene, @camera

		if @saveFrames
			frame = renderer.domElement.toDataURL.replace /^data:image\/(png|jpg);base64,/, ""
			@frames.push frame