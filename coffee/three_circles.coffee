class Scene

	constructor: (options) ->

		@WIDTH = if options.width != undefined then options.width else 500
		@HEIGHT = if options.height != undefined then options.height else 500

		@renderer = new THREE.WebGLRenderer({preserveDrawingBuffer:true, antialias:true})
		@renderer.setSize options.width, options.height
		$('#container').append @renderer.domElement

		@scene = new THREE.Scene()
		@camera = new THREE.OrthographicCamera( @WIDTH / -2, @WIDTH / 2, @HEIGHT / 2, @HEIGHT / - 2, -5000, 5000 )
		@frameLength = 1000/30
		@time = 0
		@frames = []
		@saveFrames = false
		@gui = new dat.GUI {height: 1000, width:300}
		@rotationAmount = 1
		@gui.add( this, 'rotationAmount', -4, 4 ).step .05

		@startingLevel = 0
		@numLevels = 4
		@allCircles = []
		i = 0
		while i<@numLevels
			@allCircles[i] = []
			i++

		@cameraTarget = new THREE.Vector3 # the center point where the camera renders each frame
		@cameraTargetStart = new THREE.Vector3 # where the camera starts from at the beginning of a tween
		@cameraTargetLerp = 0 # progress towards the targetCircle
		@cameraWidth = @WIDTH # the size of the camera frame
		@targetCircle = null # a circle that the camera is targeting
		@circleRotationStart = 0
		@circleRotationEnd = 0

		$('#container').on 'mousedown', (e)=>
			@reset()
			@animateIntoCircle @allCircles[@startingLevel+1][0]

	init: ->

		circleGeom		= new THREE.CircleGeometry @WIDTH/2, 100
		circleMaterial	= new THREE.MeshBasicMaterial {color:0xFFFFFF, wireframe:false}
		@circle 		= new THREE.Mesh circleGeom, circleMaterial

		@createCirclesInCircle @circle
		@scene.add @circle

		@whiteShield = new THREE.Mesh( new THREE.PlaneGeometry( 500, 500 ), new THREE.MeshBasicMaterial({transparent:true,color:0xFFFFFF}) )
		@blackShield = new THREE.Mesh( new THREE.PlaneGeometry( 500, 500 ), new THREE.MeshBasicMaterial({transparent:true,color:0x000000}) )
		@scene.add @whiteShield
		@scene.add @blackShield

		@scene.updateMatrixWorld()

		@reset()
		@update()

	reset: ->
		@targetCircle = @allCircles[@startingLevel][0]
		@cameraTarget = @getWorldPosition @targetCircle
		@cameraWidth = @targetCircle.geometry.radius * 2

		@currentShield = if @startingLevel % 2 is 0 then @whiteShield else @blackShield
		@targetCircle.add @currentShield
		@currentShield.position.z = -.01
		@targetCircle.position.z = .1

		i=0
		while i<@allCircles.length
			for c, j in @allCircles[i]
				c.rotation.z = 0
				c.material.opacity = if i > @startingLevel + 1 then 0 else 1
			i++

		@animateIntoCircle @allCircles[@startingLevel+1][0]

	animateIntoCircle: ( theCircle )->
		@targetCircle = theCircle
		@cameraTargetStart.set @cameraTarget.x, @cameraTarget.y, @cameraTarget.z
		@cameraTargetLerp = 0
		@circleRotationStart = @targetCircle.rotation.z
		@circleRotationEnd = @circleRotationStart - Math.PI * @rotationAmount

		@currentShield = ( if theCircle.level % 2 is 1 then @blackShield else @whiteShield )
		# @currentShield = @whiteShield
		@targetCircle.add @currentShield
		@currentShield.material.opacity = 0;
		@currentShield.position.z = -.01
		@targetCircle.position.z = .1

		tween = new TWEEN.Tween this
		tween.to {cameraWidth:@targetCircle.geometry.radius*2, cameraTargetLerp:1}, 1000
		tween.easing TWEEN.Easing.Quadratic.InOut
		tween.onUpdate =>
			# @targetCircle.parent.parent.rotation.z = utils.lerp( @circleRotationStart, @circleRotationEnd, @cameraTargetLerp )
			for c, i in @allCircles[@targetCircle.level-1]
				c.rotation.z = utils.lerp @circleRotationStart, @circleRotationEnd, @cameraTargetLerp

			worldPos = new THREE.Vector3
			@targetCircle.parent.parent.updateMatrixWorld()
			worldPos.getPositionFromMatrix @targetCircle.matrixWorld
			worldPos.lerp( @cameraTargetStart, 1.0 - @cameraTargetLerp )
			@cameraTarget = worldPos.clone()

			@currentShield.material.opacity = @cameraTargetLerp

			for c, i in @allCircles[@targetCircle.level]
				c.rotation.z = Math.PI * 4/3 * @cameraTargetLerp	
			for c, i in @allCircles[@targetCircle.level+1]
				c.material.opacity = @cameraTargetLerp
		tween.onComplete =>
			if ( @targetCircle.level+2 < @numLevels )
				@animateIntoCircle @allCircles[@targetCircle.level+1][0]
			else
				@reset()
		# tween.delay( 1000 )
		tween.start( @time )

	createCirclesInCircle: ( theCircle, level = 0 )->
		# make three circles
		i = 0
		numCircles = 3
		while i < numCircles
			color = if level % 2 is 1 then 0xFFFFFF else 0x000000
			opacity = if level > @startingLevel + 1 then 0 else 1
			# opacity = 1
			# http://en.wikipedia.org/wiki/Circle_packing_in_a_circle
			aCircleGeom			= new THREE.CircleGeometry theCircle.geometry.radius / (1+(2/3)*Math.sqrt(3)), 60
			aCircleMaterial		= new THREE.MeshBasicMaterial {color:color, wireframe:false, transparent:true, opacity:opacity}

			aNode				= new THREE.Object3D
			aCircle 			= new THREE.Mesh aCircleGeom, aCircleMaterial
			aCircle.position.z = .01
			aCircle.position.x = theCircle.geometry.radius - aCircle.geometry.radius
			aNode.rotation.z = (i / numCircles) * Math.PI * 2
			aNode.add aCircle
			theCircle.add aNode

			aCircle.level = level
			@allCircles[level].push( aCircle )

			if ( level+1 < @numLevels )
				@createCirclesInCircle aCircle, level+1
			i++

	getWorldPosition: ( node ) ->
		vector = new THREE.Vector3
		node.updateMatrixWorld()
		vector.getPositionFromMatrix node.matrixWorld
		return vector

	update: =>
		setTimeout (=>
			requestAnimationFrame( @update )
		), @frameLength

		TWEEN.update @time
		@time += @frameLength

		# update the first node's world matrix
		@circle.children[0].updateMatrixWorld()
		worldPos = new THREE.Vector3
		worldPos.getPositionFromMatrix @circle.children[0].children[0].matrixWorld

		@camera.left	= @cameraTarget.x - @cameraWidth/2
		@camera.right	= @cameraTarget.x + @cameraWidth/2
		@camera.top		= @cameraTarget.y + @cameraWidth/2
		@camera.bottom	= @cameraTarget.y - @cameraWidth/2
		@camera.updateProjectionMatrix()


		@renderer.render @scene, @camera

		if @saveFrames
			frame = renderer.domElement.toDataURL.replace /^data:image\/(png|jpg);base64,/, ""
			@frames.push frame






















