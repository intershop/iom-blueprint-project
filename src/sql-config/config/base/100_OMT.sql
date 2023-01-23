DO $$
DECLARE
 
BEGIN

	-- CUSTOM MENU ITEMS - https://support.intershop.com/kb/index.php/Display/2N8973
	
	DELETE FROM omt."CustomMenuItemDTO";

	-- Intershop knowledge base
	INSERT INTO omt."CustomMenuItemDTO"
		(SELECT 2, 'Documentation', 'fa fa-question-circle-o',
		'https://support.intershop.com/kb/index.php/Search?qdo=SetFilter&qtset=PRD78&qtrem=|PRD154|PRD153|PRD106|PRD97|PRD87|PRD85&qoff=0&qtext=', 1 , TRUE, NULL, FALSE);
	
	-- CUSTOM POSITION PROPERTIES - https://support.intershop.com/kb/index.php/Display/S29206
	
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
			1,						-- id of the parent block
			null,					-- don't display a label
			'Product thumbnail',
			'product',				-- group
			'ThumbnailImgUrl',		-- key
			3,						-- display as image
			false,
			1,
			true
		);	
		
	-- FEATURE TOGGLES - https://support.intershop.com/kb/index.php/Display/292B71
	
	UPDATE omt."FeatureToggleDTO"
		SET active = TRUE
		WHERE key = 'ORDER PROGRESS BAR';

	UPDATE omt."FeatureToggleDTO"
		SET active = TRUE
		WHERE key = 'ORDER CHANGE REQUEST TAB';

END;
$$;