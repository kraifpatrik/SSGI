/// @func StringSplitOnFirst(_string, _delimiter[, _dest])
///
/// @desc Splits the string in two at the first occurence of the delimiter.
///
/// @param {String} _string The string to split.
/// @param {String} _delimiter The delimiter.
/// @param {Array<String>} [_dest] The destination array. A new one is created
/// if not specified.
///
/// @return {Array<String>} An array containing `[firstHalf, secondHalf]`. If
/// the delimiter is not found in the string, then `secondHalf` equals an empty
/// string and `firstHalf` is the original string.
function StringSplitOnFirst(_string, _delimiter, _dest=[])
{
	var i = string_pos(_delimiter, _string);
	if (i == 0)
	{
		_dest[@ 0] = _string;
		_dest[@ 1] = "";
	}
	else
	{
		_dest[@ 0] = string_copy(_string, 1, i - 1);
		_dest[@ 1] = string_delete(_string, 1, i);
	}
	return _dest;
}
