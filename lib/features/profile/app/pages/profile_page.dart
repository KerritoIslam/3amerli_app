import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:amerli_app/utils/constants/app_text_styles.dart';
import 'package:amerli_app/widgets/app_button.dart';
import 'package:amerli_app/widgets/cards_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Center(
        child: SizedBox(
          width: double.infinity,
          child: Padding(

            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                Center(
                  child :Container(
                  width: double.infinity,
                  child:Column(
                    children: [SizedBox(height: 20),
                Text("Mon Profil", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24)),
                SizedBox(height: 15),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: ClipOval(
                    child: Image.network(
                      // Temporary random image until backend provides profile URLs
                      'https://picsum.photos/seed/profile/200/200',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.0, value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1) : null),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.person_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text("Nom d'utilisateur", style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 8),
                Text("Numero de téléphone", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),],
                  )
                )),
                
                SizedBox(height: 20),
                Text("Mon Compte", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: 10),
                CardsList(
                    
                  items: [
                  CardsListItem(
                    leading: SvgPicture.asset('assets/icons/Informations_personnelles.svg', width: 24, height: 24, color: Theme.of(context).iconTheme.color),
                    title: Text("Informations Personnelles", style: Theme.of(context).textTheme.titleSmall),
                  
                    onTap: () {
                      // Navigate to personal information page
                    },
                  ),
                  CardsListItem(
                    leading: SvgPicture.asset('assets/icons/moyens_de_paiement.svg', width: 24, height: 24, color: Theme.of(context).iconTheme.color),
                    title: Text("Moyens de Paiement", style: Theme.of(context).textTheme.titleSmall),
                   
                    onTap: () {
                      // Navigate to change password page
                    },
                  ),
                  CardsListItem(
                    leading: SvgPicture.asset('assets/icons/mes_commandes.svg', width: 24, height: 24, color: Theme.of(context).iconTheme.color),
                    title: Text("Mes Commandes", style: Theme.of(context).textTheme.titleSmall),
                   
                    onTap: () {
                      // Navigate to app settings page
                    },
                  ),
                ]),
                SizedBox(height: 20),
                Text("Additionnel", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: 10),
                CardsList(
                    
                  items: [
                  CardsListItem(
                    leading: SvgPicture.asset('assets/icons/support.svg', width: 24, height: 24, color: Theme.of(context).iconTheme.color),
                    title: Text("Support & Aide", style: Theme.of(context).textTheme.titleSmall),
                  
                    onTap: () {
                      // Navigate to personal information page
                    },
                  ),
                  CardsListItem(
                    leading: SvgPicture.asset('assets/icons/language.svg', width: 24, height: 24, color: Theme.of(context).iconTheme.color),
                    title: Text("Language", style: Theme.of(context).textTheme.titleSmall),
                   
                    onTap: () {
                      // Navigate to change password page
                    },
                  ),
                  
                ]),
                SizedBox(height: 30),
                AppButton(onPressed: () {}, 
                  backgroundColor: AppColors.brandRed,
                  child: Row (
                    mainAxisAlignment: MainAxisAlignment.center,
                  children: [ SvgPicture.asset('assets/icons/logout.svg', width: 24, height: 24, color: AppColors.lightOnPrimary),SizedBox(width: 18), Text("Se déconnecter" ,style: AppTextStyles.buttonLargeBold),],) ,
                )
              ],
            ),
          ),
        ),
        ),
      )
      
    );
    
  }
}