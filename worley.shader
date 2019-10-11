shader_type canvas_item;

uniform sampler2D pointsR;
uniform sampler2D pointsG;
uniform sampler2D pointsB;
uniform int numCellsR;
uniform int numCellsG;
uniform int numCellsB;
uniform int numSlices;
uniform int slice;

void fragment()
{	
	for (int channel = 0; channel < 3; channel++)
	{
		int numCellsPerAxis;
		if (channel == 0) numCellsPerAxis = numCellsR;
		else if (channel == 1) numCellsPerAxis = numCellsG;
		else if (channel == 2) numCellsPerAxis = numCellsB;
		
		float cellSize = 1.0f / float(numCellsPerAxis);
		int num_cells = numCellsPerAxis * numCellsPerAxis * numCellsPerAxis;
		vec3 samplePosition = vec3(UV, float(slice) / float(numSlices)) / cellSize;
		ivec3 curCell = ivec3(floor(samplePosition));
		
		float minSqrDist = 1.0;
		
		for (int x_offset = -1; x_offset <= 1; x_offset++)
		{
			for (int y_offset = -1; y_offset <= 1; y_offset++)
			{
				for (int z_offset = -1; z_offset <= 1; z_offset++)
				{
					ivec3 adjCell = curCell + ivec3(x_offset, y_offset, z_offset);
					
					// Wrap around if adjacent cell is out of bounds.
					if (adjCell.x == -1 || adjCell.x == numCellsPerAxis) adjCell.x = (adjCell.x + numCellsPerAxis) % numCellsPerAxis;
					if (adjCell.y == -1 || adjCell.y == numCellsPerAxis) adjCell.y = (adjCell.y + numCellsPerAxis) % numCellsPerAxis;
					if (adjCell.z == -1 || adjCell.z == numCellsPerAxis) adjCell.z = (adjCell.z + numCellsPerAxis) % numCellsPerAxis;
					
					int cellIndex = adjCell.x + numCellsPerAxis * (adjCell.y  + numCellsPerAxis * adjCell.z);
					vec3 pointPosition;
					if (channel == 0) pointPosition = texelFetch(pointsR, ivec2(cellIndex, 0), 0).xyz;
					if (channel == 1) pointPosition = texelFetch(pointsG, ivec2(cellIndex, 0), 0).xyz;
					if (channel == 2) pointPosition = texelFetch(pointsB, ivec2(cellIndex, 0), 0).xyz;
					
					vec3 cellPosition = vec3(ivec3(curCell) + ivec3(x_offset, y_offset, z_offset));
					vec3 sampleOffset = samplePosition - (pointPosition + cellPosition);
					minSqrDist = min(minSqrDist, dot(sampleOffset, sampleOffset));
				}
			}
		}
		if (channel == 0) COLOR.r = sqrt(minSqrDist);
		else if (channel == 1) COLOR.g = sqrt(minSqrDist);
		else if (channel == 2) COLOR.b = sqrt(minSqrDist);
	}
}