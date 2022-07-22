/// @func SSGI_EncodeFloat16(_real[, _dest])
///
/// @desc
///
/// @param {Real} _real
/// @param {Array<Real>} [_dest]
///
/// @return {Array<Real>}
function SSGI_EncodeFloat16(_real, _dest=[])
{
	_dest[@ 0] = frac(_real);
	_dest[@ 1] = frac(_real * 255.0);
	_dest[@ 0] -= _dest[1] / 255.0;
	return _dest;
}
