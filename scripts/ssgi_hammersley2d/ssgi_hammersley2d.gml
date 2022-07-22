/// @func SSGI_Hammersley2D(_i, _n[, _dest])
///
/// @desc Gets i-th point from sequence of uniformly distributed points on a
/// unit square.
///
/// @param {Real} _i The point index in sequence.
/// @param {Real} _n The total size of the sequence.
/// @param {Array<Real>} [_dest] The array to write the point coordinates to.
///
/// @return {Array<Real>} The destination array.
///
/// @source http://holger.dammertz.org/stuff/notes__hammersley_on_hemisphere.html
function SSGI_Hammersley2D(_i, _n, _dest=[])
{
	var _b = (_n << 16) | (_n >> 16);
	_b = ((_b & 0x55555555) << 1) | ((_b & 0xAAAAAAAA) >> 1);
	_b = ((_b & 0x33333333) << 2) | ((_b & 0xCCCCCCCC) >> 2);
	_b = ((_b & 0x0F0F0F0F) << 4) | ((_b & 0xF0F0F0F0) >> 4);
	_b = ((_b & 0x00FF00FF) << 8) | ((_b & 0xFF00FF00) >> 8);
	_dest[@ 0] = _i / _n;
	_dest[@ 1] = _b * 2.3283064365386963 * 0.0000000001;
	return _dest;
}
