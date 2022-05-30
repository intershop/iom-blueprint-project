DO $$
DECLARE
 
BEGIN

	-- CUSTOM MENU ITEMS
	
	DELETE FROM omt."CustomMenuItemDTO";

	-- Intershop support
	INSERT INTO omt."CustomMenuItemDTO"
		(SELECT 2, 'Documentation', 'fa fa-question-circle-o',
		'https://support.intershop.com/kb/index.php/Search?qdo=SetFilter&qtset=PRD78&qtrem=|PRD154|PRD153|PRD106|PRD97|PRD87|PRD85&qoff=0&qtext=',2 , TRUE, NULL, FALSE);
		
	
	-- CUSTOM POSITION PROPERTIES
	
	DELETE FROM omt."CustomPropertyPresentationDTO";
	DELETE FROM omt."CustomBlockDTO";
	
	INSERT INTO omt."CustomBlockDTO"
		(id, label, description, active)
	VALUES
		(1, 'Details', 'Block to show the product image and link.', true);
		
	INSERT INTO omt."CustomPropertyPresentationDTO"
		(id, "customBlockRef", "label", "description", "group", "key", "presentationTypeRef", "hideIfValueEmpty", "rank", "active")
	VALUES
		(
			1,
			1,                		--id of the block above
			null,               	--don't display a label
			'Product thumbnail',
			'product',				--group
			'ThumbnailImgUrl',		--key
			3,                  	--display as image
			false,
			1,
			true
		);	




		
	-- FEATURE TOGGLES
	
	UPDATE omt."FeatureToggleDTO"
		SET active = TRUE
		WHERE key = 'ORDER PROGRESS BAR';

END;
$$;