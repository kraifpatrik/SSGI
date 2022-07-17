/// @func StringExplode(_string, _char, _dest)
///
/// @desc Splits given string on every `_char` and puts created parts into an
/// array.
///
/// @param {String} _string The string to explode.
/// @param {String} _char The character to split the string on.
/// @param {Array<String>} _dest The destination array.
///
/// @return {Real} Returns number of entries written into the destination array.
function StringExplode(_string, _char, _dest)
{
	static _temp = array_create(2);
	var i = 0;
	do
	{
		StringSplitOnFirst(_string, _char, _temp);
		_dest[@ i++] = _temp[0];
		_string = _temp[1];
	}
	until (_temp[1] == "");
	return i;
}
