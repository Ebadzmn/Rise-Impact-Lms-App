import 'package:flutter/material.dart';

class TermsAndConditionsModal extends StatelessWidget {
  const TermsAndConditionsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Term & Condition',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      '1. Acceptance of Terms',
                      'By using the RISE & IMPACT service, you agree to be bound by these Terms of Service.',
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      '2. Use of Service',
                      'You agree to use the service only for lawful purposes and in a manner that does not infringe the rights of, or restrict or inhibit the use and enjoyment of the service by any third party.',
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      '3. Privacy Policy',
                      'Your use of the service is also governed by our Privacy Policy, which is incorporated into these Terms of Service.',
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      '4. Termination',
                      'We may terminate or suspend access to the service immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach these Terms of Service.',
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      '5. Disclaimer of Warranties',
                      'The service is provided on an "as is" and "as available" basis. We make no representations or warranties of any kind, express or implied, about the operation of the service, or the information, content, materials, or products included on the service.',
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      '6. Limitation of Liability',
                      'In no event will we be liable for any loss or damage including without limitation, indirect or consequential loss or damage, or any loss or damage whatsoever arising from loss of data or profits arising out of or in connection with the use of this service.',
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      '7. Governing Law',
                      'These Terms of Service shall be governed by and construed in accordance with the laws of the State of California, without regard to its conflict of law principles.',
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF6A7554,
                    ), // Sage Green from design
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
