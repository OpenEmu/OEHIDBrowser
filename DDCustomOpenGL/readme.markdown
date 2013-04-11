This sample code demonstrates how to create a custom OpenGL NSView subclass
that can enter full screen mode and use a Core Video display link to drive the
animation. It is sort of a mash-up of the [Custom Cocoa OpenGL] [1] the OpenGL
game template (which seems to have been removed) sample code, with the
addition of Core Video. The view uses two OpenGL contexts, one for windowed
mode and one for full screen mode. The full screen context is shared with the
windowed context, so textures created for the windowed mode are available in
the full screen mode. This code also shows how to create textures using Core
Video. The DDCustomOpenGLView class may be used in other projects by
subclassing.

The code is released under an [MIT license] [2].

Some things I learned:

 - Don't use the OpenGL lock around the display link. This can cause
   deadlocks, as the display link has it's own mutex.

 - OpenGL textures loaded from an Core Graphics image need to be flipped.

 - For double-buffered contexts, call [NSOpenGLContext flushBuffer], and for
   single-buffered contexts, call glFlush().

[1]: http://developer.apple.com/samplecode/Custom_Cocoa_OpenGL/index.html

[2]: http://www.opensource.org/licenses/mit-license.html

Document Revision History
-------------------------

<table cellspacing="0" width="90%" border="1">
  <tr style="background-color: #cccccc">
    <th width="100">Date</th>
  	<th>Notes</th>
	</tr>
	<tr>
	  <td>2006-10-23</td>
	  <td>
	    Initial release.
	  </td>
	</tr>
</table>
