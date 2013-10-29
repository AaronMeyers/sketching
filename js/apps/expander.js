var camera, renderer, scene;

var initialHeight = 10;
var whitePlane, blackPlane;
var whiteNode, blackNode;
var WIDTH = 500, HEIGHT = 500;

var time = 0;
var frames = new Array();
var saveFrames = true;

var rumbleAmount = 25;
var rumbleLength = 500;
var expandLength = 300;

var frameLength = 1000/30;

init();
animate();


function init() {
	renderer = new THREE.WebGLRenderer({preserveDrawingBuffer:true});
	renderer.setSize( 500, 500 );
	document.getElementById( 'container' ).appendChild( renderer.domElement );
	
	scene = new THREE.Scene();
	camera = new THREE.OrthographicCamera( 0, WIDTH, HEIGHT / 2, HEIGHT / - 2, - 5000, 5000 );


	var planeGeom = new THREE.PlaneGeometry( 1, 1, 1, 1 );

	whitePlane = new THREE.Mesh( planeGeom, new THREE.MeshBasicMaterial({color:0xFFFFFF}) );
	whitePlane.position.x = .5;
	blackPlane = new THREE.Mesh( planeGeom, new THREE.MeshBasicMaterial({color:0x000000}) );
	blackPlane.position.x = .5;

	whiteNode = new THREE.Object3D();
	blackNode = new THREE.Object3D();
	whiteNode.name = "whiteNode";
	blackNode.name = "blackNode";

	whiteNode.add( whitePlane );
	blackNode.add( blackPlane );
	blackNode.position.x = 500;
	blackNode.rotation.z = Math.PI;
	blackNode.scale.set( 500, 500, 1 );

	scene.add( whiteNode );
	scene.add( blackNode );

	$('#download').hide()
	$('#download').on( 'click', saveFramesToZip );

	initGUI();

	expand( whiteNode, WIDTH, HEIGHT );

}

function initGUI() {

	gui = new dat.GUI({
		height: 1000,
		width:300
	});

	gui.add( this, 'rumbleAmount', 20, 100 );
	gui.add( this, 'rumbleLength', 0, 1000 );
	gui.add( this, 'expandLength', 0, 1000 );
	// gui.add( this, 'blah' );
}

function blah() {
	console.log( 'blah' );
}

function saveFramesToZip() {
	var pad = function(n, width, z) {
		z = z || '0';
		n = n + '';
		return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
	}

	var zip = new JSZip();
	var folder = zip.folder( "frames" );
	for ( var i=0; i<frames.length; i++ ) {
		folder.file( "frame" + pad(i,3,0) + ".png", frames[i], {base64:true} );
	}
	location.href = "data:application/zip;base64,"+zip.generate();
}

function expand( node, scaleX, scaleY ) {

	node.scale.y = initialHeight;
	node.scale.x = 0;
	node.position.z = 1;

	var tween = new TWEEN.Tween({
		node: node,
		scaleX: node.scale.x
	})
	.to({scaleX:scaleX}, 300)
	.delay( saveFrames ? 0 : 500 )
	.easing( TWEEN.Easing.Quadratic.InOut )
	.onUpdate(function(){
		this.node.scale.x = this.scaleX;
	});

	var rumbleUpTween = new TWEEN.Tween({
		node: node,
		rumble: 0
	})
	.to({rumble:1}, rumbleLength)
	.delay( saveFrames ? 0 : 500 )
	.onUpdate(function(){
		this.node.position.y = utils.random( -rumbleAmount * this.rumble, rumbleAmount * this.rumble );
		this.node.scale.y = initialHeight + initialHeight * this.rumble;
	});

	var finalTween = new TWEEN.Tween({
		node: node,
		scaleY: node.scale.y
	})
	.to({scaleY:scaleY}, expandLength)
	.easing( TWEEN.Easing.Circular.InOut )
	.onUpdate(function(){
		this.node.scale.y = this.scaleY;
	})
	.onStart(function(){
		this.node.position.y = 0;
	})
	.onComplete(function(){
		this.node.position.z = 0;
		expand( this.node==whiteNode?blackNode:whiteNode, WIDTH, HEIGHT );
		if ( saveFrames && this.node == blackNode ) {
			saveFrames = false
			$('#download').fadeIn();
		}
	})

	tween.chain( rumbleUpTween );
	rumbleUpTween.chain( finalTween );
	tween.start( time );

}

function animate() {

	// requestAnimationFrame( animate );
	setTimeout( function() {
        requestAnimationFrame( animate );
    }, frameLength );

	TWEEN.update( time );
	time += frameLength;
	renderer.render(scene, camera);

	if ( saveFrames ) {
		frames.push( renderer.domElement.toDataURL("image/png").replace(/^data:image\/(png|jpg);base64,/, "") );
	}

}