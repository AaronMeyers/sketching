class Scene

	constructor: (options) ->

		@WIDTH = if options.width != undefined then options.width else 500
		@HEIGHT = if options.height != undefined then options.height else 500

		@renderer = new THREE.WebGLRenderer({preserveDrawingBuffer:true, antialias:true})
		@renderer.setSize options.width, options.height
		$('#container').append @renderer.domElement

		@scene = new THREE.Scene()
		@camera = new THREE.OrthographicCamera( @WIDTH / -2, @WIDTH / 2, @HEIGHT / 2, @HEIGHT / - 2, -5000, 5000 )
		@frameLength = 1000/60
		@time = 0
		@frames = []
		@saveFrames = false
		@gui = new dat.GUI {height: 1000, width:300}

		@cameraTarget = new THREE.Vector3 # the center point where the camera renders each frame
		@cameraTargetStart = new THREE.Vector3 # where the camera starts from at the beginning of a tween
		@cameraTargetLerp = 0 # progress towards the targetCircle
		@cameraWidth = @WIDTH # the size of the camera frame
		@targetCircle = null # a circle that the camera is targeting
		@circleRotationStart = 0
		@circleRotationEnd = 0


		#mouse stuff
		@mousePos = new THREE.Vector2
		@mouseDown = false;
		$('#container').on 'mousedown', (e)=>
			@targetCircle = @circle.children[0].children[0]
			@cameraTargetStart.set @cameraTarget.x, @cameraTarget.y, @cameraTarget.z
			@cameraTargetLerp = 0
			@circleRotationStart = @targetCircle.rotation.z
			@circleRotationEnd = -Math.PI

			tween = new TWEEN.Tween this
			tween.to {cameraWidth:@targetCircle.geometry.radius*2, cameraTargetLerp:1}, 1000
			tween.easing TWEEN.Easing.Quadratic.InOut
			tween.onUpdate =>
				# console.log @cameraWidth
				# get the targets world position
				worldPos = new THREE.Vector3
				@targetCircle.parent.parent.rotation.z = utils.lerp( @circleRotationStart, @circleRotationEnd, @cameraTargetLerp )
				@targetCircle.parent.updateMatrixWorld()
				worldPos.getPositionFromMatrix @targetCircle.matrixWorld
				worldPos.lerp( @cameraTargetStart, 1.0 - @cameraTargetLerp )
				@cameraTarget = worldPos.clone()



			tween.start()
			# @mouseDown = true;
			# @mousePos.set e.offsetX - @WIDTH/2, (@HEIGHT - e.offsetY - @HEIGHT/2)
			# $('#container').on 'mousemove', (e)=>
			# 	@mousePos.set e.offsetX - @WIDTH/2, (@HEIGHT - e.offsetY - @HEIGHT/2)
			# $('#container').on 'mouseup', (e)=>
			# 	@mouseDown = false
			# 	$('#container').off 'mousemove'

		@smallSize = 200
		@gui.add this, 'smallSize', 100, 500

	init: ->

		circleGeom		= new THREE.CircleGeometry @WIDTH/2, 60
		circleMaterial	= new THREE.MeshBasicMaterial {color:0xFFFFFF}
		@circle 		= new THREE.Mesh circleGeom, circleMaterial

		# make three circles
		i = 0
		numCircles = 3
		while i < numCircles
			# http://en.wikipedia.org/wiki/Circle_packing_in_a_circle
			aCircleGeom			= new THREE.CircleGeometry @circle.geometry.radius / (1+(2/3)*Math.sqrt(3)), 60
			aCircleMaterial		= new THREE.MeshBasicMaterial {color:0x000000}

			aNode				= new THREE.Object3D
			aCircle 			= new THREE.Mesh aCircleGeom, aCircleMaterial
			aCircle.position.z = 1
			aCircle.position.x = @circle.geometry.radius - aCircle.geometry.radius
			aNode.rotation.z = (i / numCircles) * Math.PI * 2
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

		# @circle.rotation.z += .01

		# update the first node's world matrix
		@circle.children[0].updateMatrixWorld()
		worldPos = new THREE.Vector3
		worldPos.getPositionFromMatrix @circle.children[0].children[0].matrixWorld

		# @cameraTarget = worldPos.clone()

		@camera.left	= @cameraTarget.x - @cameraWidth/2
		@camera.right	= @cameraTarget.x + @cameraWidth/2
		@camera.top		= @cameraTarget.y + @cameraWidth/2
		@camera.bottom	= @cameraTarget.y - @cameraWidth/2
		@camera.updateProjectionMatrix()


		@renderer.render @scene, @camera

		if @saveFrames
			frame = renderer.domElement.toDataURL.replace /^data:image\/(png|jpg);base64,/, ""
			@frames.push frame






















