/**
 * @author alteredq / http://alteredqualia.com/
 *
 * Invert one texture with the other
 */

THREE.InvertShader = {

	uniforms: {

		"tDiffuse1": { type: "t", value: null },
		"tDiffuse2": { type: "t", value: null }

	},

	vertexShader: [

		"varying vec2 vUv;",

		"void main() {",

			"vUv = uv;",
			"gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );",

		"}"

	].join("\n"),

	fragmentShader: [

		"uniform sampler2D tDiffuse1;",
		"uniform sampler2D tDiffuse2;",

		"varying vec2 vUv;",

		"void main() {",

			"vec4 texel1 = texture2D( tDiffuse1, vUv );",
			"vec4 texel2 = texture2D( tDiffuse2, vUv );",
			"vec3 diff = texel1.rgb * (1.0-texel2.rgb) + texel2.rgb * (1.0-texel1.rgb);",
			"gl_FragColor = vec4( diff, 1.0 );",
		"}"

	].join("\n")

};
