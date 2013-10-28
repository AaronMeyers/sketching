var camera, renderer, scene;

var initialHeight = 10;
var whitePlane, blackPlane;
var whiteNode, blackNode;
var WIDTH = 500, HEIGHT = 500;

var time = 0;
var frames = new Array();
var saveFrames = true;
var finishFrames = false;

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

	expand( whiteNode, WIDTH, HEIGHT );

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
		this.node.position.z = 0;
		expand( this.node==whiteNode?blackNode:whiteNode, WIDTH, HEIGHT );
		if ( saveFrames && this.node == blackNode ) {
			saveFrames = false
			finishFrames = true;
		}
	})

	tween.chain( nextTween );
	tween.start( time );

}

function animate() {

	// requestAnimationFrame( animate );
	setTimeout( function() {
        requestAnimationFrame( animate );
    }, 1000 / 30.0 );

	TWEEN.update( time );
	time += (1000 / 30.0 );
	renderer.render(scene, camera);

	if ( saveFrames ) {
		frames.push( renderer.domElement.toDataURL("image/png").replace(/^data:image\/(png|jpg);base64,/, "") );
	}
	if ( finishFrames ) {
		saveFramesToZip();
		saveFrames = false;
		finishFrames = false;
	}

}