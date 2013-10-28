var camera, renderer, scene;

var initialHeight = 10;
var whitePlane, blackPlane;
var whiteNode, blackNode;
var WIDTH = 500, HEIGHT = 500;

init();
animate();


function init() {
	renderer = new THREE.WebGLRenderer();
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
	// blackNode.scale.x = 500;
	blackNode.position.x = 500;
	blackNode.rotation.z = Math.PI;

	scene.add( whiteNode );
	scene.add( blackNode );


	expand( whiteNode, WIDTH, HEIGHT );

}

var expandCount = 0;

function expand( node, scaleX, scaleY ) {

	node.scale.y = initialHeight;
	node.scale.x = 0;
	node.position.z = 1;

	var tween = new TWEEN.Tween({
		node: node,
		scaleX: node.scale.x
	})
	.to({scaleX:scaleX}, 300)
	.easing( TWEEN.Easing.Quadratic.InOut )
	.onUpdate(function(){
		this.node.scale.x = this.scaleX;
	})

	var nextTween = new TWEEN.Tween({
		node: node,
		scaleY: node.scale.y
	})
	.to({scaleY:scaleY}, 300)
	.easing( TWEEN.Easing.Quadratic.InOut )
	.onUpdate(function(){
		this.node.scale.y = this.scaleY;
	})
	.onComplete(function(){
		// console.log( 'complete' );
		// expand( whiteNode, WIDTH, HEIGHT );
		this.node.position.z = 0;
		expand( this.node==whiteNode?blackNode:whiteNode, WIDTH, HEIGHT );
	})

	tween.chain( nextTween );
	tween.start();

}

function animate() {

	requestAnimationFrame( animate );

	TWEEN.update();
	renderer.render(scene, camera);

}